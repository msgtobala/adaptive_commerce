import 'dart:async';

import 'package:adaptive_commerce/core/firebase/firebase_ai_config.dart';
import 'package:adaptive_commerce/core/firebase/firebase_providers.dart';
import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/features/food/pet_profile_prompt.dart';
import 'package:adaptive_commerce/features/onboarding/pet_profile.dart';
import 'package:adaptive_commerce/features/onboarding/pet_profile_provider.dart';
import 'package:adaptive_commerce/features/toys/catalog/toys_catalog.dart';
import 'package:adaptive_commerce/features/toys/tools/toys_firestore_tool.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:firebase_ai/firebase_ai.dart' as firebase_ai;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';

import 'package:adaptive_commerce/core/widgets/shell_prompt_bar.dart';

/// Toys assistant: GenUI + Firebase AI + Firestore-backed toy catalog tool.
class ToysPage extends ConsumerStatefulWidget {
  const ToysPage({super.key});

  @override
  ConsumerState<ToysPage> createState() => _ToysPageState();
}

class _ToysPageState extends ConsumerState<ToysPage> {
  late final GenUiConversation _conversation;
  final List<String> _surfaceIds = [];
  bool _didBootstrap = false;

  @override
  void initState() {
    super.initState();

    final catalog = toysCatalog;
    final firebaseAI = ref.read(firebaseAIProvider);
    final firestore = ref.read(firebaseFirestoreProvider);
    final processor = A2uiMessageProcessor(catalogs: [catalog]);

    final contentGenerator = FirebaseAiContentGenerator(
      catalog: catalog,
      systemInstruction: _toysSystemInstruction,
      additionalTools: [
        createToysFetchTool(firestore),
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
            toysTabMessageWithProfile(
              profile,
              'Welcome the user to Toys. Render exactly one ToyTopicAdvice matching '
              'the Veterinary welcome layout: title "Toys"; summary a friendly paragraph '
              'that greets them and mentions play, enrichment, and safe toys for their pet '
              '(use the pet name from the profile when present); then exactly **seven** '
              'bullets under "You can ask about" with short example questions. One bullet '
              'must be: "Suggest toys for teething behavior". Do not include any other widgets.',
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
        UserMessage.text(toysTabMessageWithProfile(profile, text)),
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
                AppStrings.navToys,
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

String toysTabMessageWithProfile(PetProfile profile, String userQuestion) {
  return '${formatPetProfileForPrompt(profile)}\n\nUser question:\n$userQuestion';
}

const String _toysSystemInstruction = '''
You are Happy Paws’ Toys assistant. The user message always includes a
**Pet profile** block and a **User question**. Respect the profile (pet type,
age, breed, gender) for enrichment and safety suggestions.

You MUST render exactly ONE primary catalog widget per response (do NOT render multiple).
Catalog widgets:
1. **ToySuggestionResults** — shop listings from Firestore (names, prices, Buy now).
2. **ToyTopicAdvice** — welcome + “You can ask about:” example prompts (bootstrap / intro only).

CRITICAL — toy shopping & suggestions (read carefully):
- If the user asks to **suggest**, **find**, **recommend**, **buy**, **shop**, names **teething**,
  **chew**, **puppy/kitten toys**, **durable toys**, or any similar shopping or product request:
  you **MUST** (1) call **fetch_toys_from_firestore** first, then (2) render **ToySuggestionResults**
  populated from the tool’s **toys[]**. Do **not** answer with only generic Text, Column, or
  CoreCatalogItems.text for these requests — the **ToySuggestionResults** widget is mandatory.
- For those product/suggestion turns, you MUST call **beginRendering** with a NEW unique **surfaceId**
  and set **root** to the ToySuggestionResults component id for that turn (for example
  `toy_suggestions_<turnId>`). Do NOT rely on only surfaceUpdate on an existing root.
- You **MUST NOT** say you “couldn’t find toys in our catalog” or imply the store is empty
  **until after** the tool has run. Never invent inventory; use only tool output.
- If **filter_fallback** is true in the tool response, mention in **summary** that listings are
  from the full catalog because no row matched the search text (e.g. product names rarely say “teething”).

**fetch_toys_from_firestore**
- Call it **before** every **ToySuggestionResults** for product/suggestion turns.
- Pass **search_query** from the user message (e.g. "teething", "chew"); typos are OK. Use **""**
  (empty) for a broad pull.
- Map **toys[]** into **ToySuggestionResults.products[]**: **name**, **price**, **seller**, **url**
  exactly as returned; **productId** = tool **id**.
- If **toys[]** is empty and there is no **error**, use **products: []** and a short **summary**
  explaining Firestore returned no documents (still render **ToySuggestionResults**).
- If **error** is present, still render **ToySuggestionResults** with **products: []** and mention
  the fetch failed (do not fabricate products).

Routing:
- Product / suggestion / teething / shopping language → **ToySuggestionResults** + tool (above).
- Only the **first bootstrap** welcome (“Welcome the user to Toys…”) → **ToyTopicAdvice** only;
  do **not** call the Firestore tool for that message.

**ToySuggestionResults** fields:
- **title**: short headline (e.g. include pet name when helpful).
- **summary**: tie results to the question and profile; add safety note if appropriate.
- **products**: all rows you are showing from **toys[]** (up to ~6 is fine).

**ToyTopicAdvice** (welcome only):
- **title**: "Toys"
- **summary**: welcome paragraph (pet name when available).
- **bullets**: exactly 7 example questions; include **Suggest toys for teething behavior**.

Safety: supervision for chews/small parts; vet when unsure.

GenUI protocol (strict):
- On every assistant turn, start a NEW surface via **beginRendering** with a unique `surfaceId`.
- The beginRendering **root** MUST be the primary widget for that turn:
  - ToyTopicAdvice turn -> root points to ToyTopicAdvice component id.
  - ToySuggestionResults turn -> root points to ToySuggestionResults component id.
- Use **surfaceUpdate** only to provide/update components for that same turn/surface.
- Do not update an old surface while keeping an unrelated old root.
- Toys catalog widgets only; prefer one surface per turn; then call **provideFinalOutput**.
''';
