import 'dart:async';

import 'package:adaptive_commerce/core/firebase/firebase_ai_config.dart';
import 'package:adaptive_commerce/core/firebase/firebase_providers.dart';
import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/core/widgets/shell_prompt_bar.dart';
import 'package:adaptive_commerce/features/food/catalog/food_catalog.dart';
import 'package:adaptive_commerce/features/food/pet_profile_prompt.dart';
import 'package:adaptive_commerce/features/food/tools/pet_food_search_tool.dart';
import 'package:adaptive_commerce/features/onboarding/pet_profile_provider.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:firebase_ai/firebase_ai.dart' as firebase_ai;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';

/// Food assistant: GenUI + Firebase AI (GenUI tools + optional web search tool).
class FoodPage extends ConsumerStatefulWidget {
  const FoodPage({super.key});

  @override
  ConsumerState<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends ConsumerState<FoodPage> {
  late final GenUiConversation _conversation;
  final List<String> _surfaceIds = [];
  bool _didBootstrap = false;

  @override
  void initState() {
    super.initState();

    final catalog = foodCatalog;
    final firebaseAI = ref.read(firebaseAIProvider);

    final processor = A2uiMessageProcessor(catalogs: [catalog]);

    final contentGenerator = FirebaseAiContentGenerator(
      catalog: catalog,
      systemInstruction: _foodSystemInstruction,
      additionalTools: [
        createPetFoodHardcodedSearchTool(),
      ],
      modelCreator:
          ({
            required FirebaseAiContentGenerator configuration,
            firebase_ai.Content? systemInstruction,
            List<firebase_ai.Tool>? tools,
            firebase_ai.ToolConfig? toolConfig,
          }) {
            return GeminiGenerativeModel(
              firebaseAI.generativeModel(
                model: FirebaseAiConfig.generativeModel,
                systemInstruction: systemInstruction,
                tools: tools,
                toolConfig: toolConfig,
              ),
            );
          },
    );

    _conversation = GenUiConversation(
      a2uiMessageProcessor: processor,
      contentGenerator: contentGenerator,
      onSurfaceAdded: (e) {
        setState(() {
          if (!_surfaceIds.contains(e.surfaceId)) {
            _surfaceIds.add(e.surfaceId);
          }
        });
      },
      onSurfaceDeleted: (e) {
        setState(() {
          _surfaceIds.remove(e.surfaceId);
        });
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didBootstrap) return;
      _didBootstrap = true;
      final profile = ref.read(petProfileProvider);
      unawaited(
        _conversation.sendRequest(
          UserMessage.text(
            foodTabMessageWithProfile(
              profile,
              'Welcome the user to Food. On a new surface, render exactly one '
              'PetTopicAdvice: topic "general", title "Food", summary inviting '
              'questions about pet food and eating, and exactly **seven** bullets '
              'with short example prompts. The first five may be general food topics '
              '(e.g. best food for my pet, compare two foods, how much to feed, '
              'whether an ingredient or food is safe, feeding habits). The **sixth** '
              'bullet must be: "What ingredients should I look for on a pet food label?" '
              'The **seventh** must be: "How do I transition my pet to a new food safely?" '
              'Do not include toy, chewing, or play prompts. Use beginRendering and '
              'surfaceUpdate per GenUI. Then call provideFinalOutput with a one-line '
              'greeting.',
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _conversation.dispose();
    super.dispose();
  }

  void _onPromptSend(String text) {
    if (_conversation.contentGenerator.isProcessing.value) return;
    final profile = ref.read(petProfileProvider);
    unawaited(
      _conversation.sendRequest(
        UserMessage.text(foodTabMessageWithProfile(profile, text)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShellPageScaffold(
      onPromptSend: _onPromptSend,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
              child: Text(
                AppStrings.navFood,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.headline),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _conversation.contentGenerator.isProcessing,
              builder: (context, processing, _) {
                if (!processing) return const SizedBox.shrink();
                return const Padding(
                  padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                  child: LinearProgressIndicator(minHeight: 2),
                );
              },
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _surfaceIds.length,
                itemBuilder: (context, index) {
                  final id = _surfaceIds[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GenUiSurface(
                      host: _conversation.host,
                      surfaceId: id,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const String _foodSystemInstruction = '''
You are Happy Paws’ Food assistant. The user message always includes a
**Pet profile** block and a **User question**. Respect the profile (species, age,
breed, gender) for every answer.

**Real shopping links (critical)** — Users expect buyable, real retailer pages, not demos.
- Every **sourceUrl** (and entries in **sources[]** when used) MUST be a valid **https://** URL.
- **CRITICAL RULE FOR SEARCH URLS:** URLs starting with `https://vertexaisearch.cloud.google.com/` ARE valid and safe. They are official tracking redirects to real pet-food retailers. You MUST accept them and use them exactly as provided. Do NOT treat them as placeholders and do NOT reject them.
- When generating your own links, **prefer India-friendly stores** (e.g., amazon.in, supertails.com, thepetproject.com, www.royalcanin.com/in).
- **Never** use placeholder hosts like example.com, localhost, or invented domains.
- **retailer**: set to the human-readable store name. If the search tool provides a raw domain, format it nicely (e.g., "Petsupermarket" instead of "petsupermarket.com").
- **priceDisplay** / **rating**: Prefer values you can justify from general product knowledge; if unsure,
  use cautious wording such as “Check site for current price” or omit rating rather than inventing a precise star count.

**search_web_for_pet_food** (custom tool) — For buy links and live retail listings, call this **before**
building **FoodProductResults** when the user asks what to buy, best food products, where to shop, or
similar. Pass **search_query** using the pet profile (species, age, breed) and India-friendly retailers.
The tool returns JSON `results[]` with `product_name`, `url`, `price`, `retailer`. Map each item directly into
**FoodProductResults.products[]** (use `url` as **sourceUrl**, **retailer** as retailer). You must trust the `url` provided by this tool.

For comparison requests, if tool results include extended fields (for example:
`primary_ingredients`, `food_form`, `size_options`, `current_price`, `price_per_100g`,
`target_breed_size`, `key_benefits`, `suitability`, `special_features`,
`nutritional_analysis`, `key_nutrients`), use these to build **ProductComparisonTable** rows.
Prefer rows in this order:
1) Link
2) Primary Ingredients
3) Food Form
4) Size Options
5) Current Price
6) Price per 100g
7) Target Breed Size
8) Key Benefits
9) Suitability
10) Special Features
11) Nutritional Analysis
12) Key Nutrients
Set column labels to product names and include source links in table sources.

Pick **exactly one** primary catalog widget for this turn (widget names must match):

1. **FoodProductResults** — food recommendations / “what food should I give”.
   products[]: name, priceDisplay, rating, description, ingredients[], sourceUrl,
   optional retailer. **sourceUrl must follow the Real shopping links rules above.**

2. **ProductComparisonTable** — compare foods. columnLabels + rows (label, values[]).

3. **FeedingQuantityGuide** — how much to feed for a named product. productName,
   summary, rows[] each { band, amount } (weight or life stage band and feeding amount),
   optional caution, sourceUrl (**same real-URL rules as FoodProductResults**).

4. **PetFoodSafetyAnswer** — “Can I feed …?” style safety. questionSummary,
   safeLevel, explanation, optional bullets[], sources[]. **sources[]** must use the same **Real shopping links** rules.

5. **PetHabitTips** — feeding habit do’s and don’ts. title, dos[], donts[],
   optional sources[] (real URLs only; same rules).

6. **PetTopicAdvice** — welcome copy or misc food Q&A. Fields: title, topic,
   summary, bullets[], optional dos[], donts[], sources[] (real URLs only).
   **topic must be exactly one of:** general, treats, transition. Do not use
   toys, behavior, chewing, or non-food topics.

**GenUI protocol**
- Create or update surfaces with **beginRendering**, **surfaceUpdate**, and catalog
  widgets only from this app’s Food catalog (names above).
- Prefer **one new surface per answer** (append to the conversation). You may use
  Column/Text for short labels around the main widget.
- When done with UI for the turn, you **must** call **provideFinalOutput** with a
  short summary string for the chat transcript.

**Safety**
- Feeding and health are not a substitute for a veterinarian; state that when
  giving quantities or medical-adjacent advice.

Be concise in widget copy; put detail in structured fields.
''';
