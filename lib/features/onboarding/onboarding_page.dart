import 'dart:async';

import 'package:adaptive_commerce/core/firebase/firebase_ai_config.dart';
import 'package:adaptive_commerce/core/firebase/firebase_providers.dart';
import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/core/widgets/app_brand_header.dart';
import 'package:adaptive_commerce/features/onboarding/pet_profile_provider.dart';
import 'package:adaptive_commerce/core/widgets/shell_prompt_bar.dart';
import 'package:adaptive_commerce/features/onboarding/catalog/onboarding_catalog.dart';
import 'package:firebase_ai/firebase_ai.dart' as firebase_ai;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';

/// Collects pet profile via GenUI + Firebase AI, with a bottom chat bar.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final GenUiConversation _conversation;
  final List<String> _surfaceIds = [];
  bool _didBootstrap = false;

  @override
  void initState() {
    super.initState();

    final catalog = onboardingCatalog;
    final firebaseAI = ref.read(firebaseAIProvider);

    final processor = A2uiMessageProcessor(catalogs: [catalog]);

    final contentGenerator = FirebaseAiContentGenerator(
      catalog: catalog,
      systemInstruction: _onboardingSystemInstruction,
      modelCreator: ({
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
      // Reset must run after build — not in [initState] — or Riverpod throws.
      ref.read(petProfileProvider.notifier).reset();
      unawaited(
        _conversation.sendRequest(
          UserMessage.text(
            'Start pet onboarding. Show only the first step (pet type) using '
            'the PetTypeDropdown widget on a new surface. Use beginRendering '
            'and surfaceUpdate as required by the GenUI protocol.',
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
    unawaited(_conversation.sendRequest(UserMessage.text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBrandHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Text(
                      AppStrings.onboardingTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _conversation.contentGenerator.isProcessing,
                    builder: (context, processing, _) {
                      if (!processing) return const SizedBox.shrink();
                      return const Padding(
                        padding: EdgeInsets.only(top: 8),
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
          ),
          ShellPromptBar(onSend: _onPromptSend),
        ],
      ),
    );
  }
}

/// Guides the model: **one onboarding step per user turn** (stops multi-step
/// tool loops that skipped user input).
const String _onboardingSystemInstruction = '''
You are a pet onboarding assistant. Collect profile fields in this strict order:
(1) PetTypeDropdown → (2) PetNameInput → (3) PetDobCalendar → (4) PetBreedDropdown
→ (5) PetGenderRadio → (6) PetProfileCard summary.

CRITICAL — ONE STEP PER ASSISTANT TURN:
- After each user message (typed chat OR UI event `onboardingFieldSubmitted`),
  you may build UI for **exactly one** step only.
- Use beginRendering, surfaceUpdate, deleteSurface, and dataModelUpdate only to
  produce **one** surface that contains **one** main onboarding widget for the
  current step (names: PetTypeDropdown, PetNameInput, PetDobCalendar,
  PetBreedDropdown, PetGenderRadio, or PetProfileCard).
- In the **same** turn, after that single step’s surface is ready, you MUST call
  **provideFinalOutput** with a short string (e.g. what you asked or a one-line
  confirmation). Do not start the next step in this turn.
- Never emit multiple steps (e.g. pet type and name) in one turn. Wait for the
  next message before the following step.
- If the user answers via chat text (e.g. "dog", "Max"), treat it as input for
  the current step, then show only the **next** step in your **next** turn.

Layout: combine Column/Text/Card with the one main widget. Widget names must match
exactly. PetProfileCard shows client-side Continue; still render that surface when
all fields are complete. Be brief in helper Text.
''';
