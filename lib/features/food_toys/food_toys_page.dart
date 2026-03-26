import 'dart:async';

import 'package:adaptive_commerce/core/firebase/firebase_ai_config.dart';
import 'package:adaptive_commerce/core/firebase/firebase_providers.dart';
import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/core/widgets/shell_prompt_bar.dart';
import 'package:adaptive_commerce/features/food_toys/catalog/food_toys_catalog.dart';
import 'package:adaptive_commerce/features/food_toys/pet_profile_prompt.dart';
import 'package:adaptive_commerce/features/onboarding/pet_profile_provider.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:firebase_ai/firebase_ai.dart' as firebase_ai;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';

/// Food & toys assistant: GenUI + Firebase AI (GenUI function tools only).
class FoodToysPage extends ConsumerStatefulWidget {
  const FoodToysPage({super.key});

  @override
  ConsumerState<FoodToysPage> createState() => _FoodToysPageState();
}

class _FoodToysPageState extends ConsumerState<FoodToysPage> {
  late final GenUiConversation _conversation;
  final List<String> _surfaceIds = [];
  bool _didBootstrap = false;

  @override
  void initState() {
    super.initState();

    final catalog = foodToysCatalog;
    final firebaseAI = ref.read(firebaseAIProvider);

    final processor = A2uiMessageProcessor(catalogs: [catalog]);

    final contentGenerator = FirebaseAiContentGenerator(
      catalog: catalog,
      systemInstruction: _foodToysSystemInstruction,
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
            foodToysMessageWithProfile(
              profile,
              'Welcome the user to Food & toys. On a new surface, render exactly one '
              'PetTopicAdvice: topic "general", title "Food & toys", summary inviting '
              'questions, bullets with short example prompts (food for my pet, compare '
              'foods, feeding amounts, food safety, habits, toys, chewing behavior). '
              'Use beginRendering and surfaceUpdate per GenUI. Then call '
              'provideFinalOutput with a one-line greeting.',
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
        UserMessage.text(foodToysMessageWithProfile(profile, text)),
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
                AppStrings.navFoodToys,
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

const String _foodToysSystemInstruction = '''
You are Happy Paws’ Food & Toys assistant. The user message always includes a
**Pet profile** block and a **User question**. Respect the profile (species, age,
breed, gender) for every answer.

Use the pet profile and question to produce practical guidance. Do not claim live
web or retailer data unless the user pasted it; avoid fabricated exact prices.

Pick **exactly one** primary catalog widget for this turn (widget names must match):

1. **FoodProductResults** — food recommendations / “what food should I give”.
   products[]: name, priceDisplay, rating, description, ingredients[], sourceUrl,
   optional retailer.

2. **ProductComparisonTable** — compare products. columnLabels + rows (label, values[]).

3. **FeedingGuide** — how much to feed for a named product. productName, summary,
   lines[] (each string like "5–10 kg adult: 1 cup twice daily"), optional caution,
   sourceUrl.

4. **PetTopicAdvice** — food safety (“carrots?”), feeding habits do/don’t, toy ideas,
   biting/behavior, or any other food/toy Q&A. Fields: title, topic (one of
   food_safety, feeding_habits, toys, behavior, general), summary, bullets[],
   optional dos[], donts[], sources[]. Use dos/donts when habits; bullets for lists;
   topic=behavior for chewing/biting questions.

**GenUI protocol**
- Create or update surfaces with **beginRendering**, **surfaceUpdate**, and catalog
  widgets only from this app’s Food & Toys catalog (names above).
- Prefer **one new surface per answer** (append to the conversation). You may use
  Column/Text for short labels around the main widget.
- When done with UI for the turn, you **must** call **provideFinalOutput** with a
  short summary string for the chat transcript.

**Safety**
- Feeding and health are not a substitute for a veterinarian; state that when
  giving quantities or medical-adjacent advice.

Be concise in widget copy; put detail in structured fields.
''';
