import 'dart:async';

import 'package:adaptive_commerce/core/firebase/firebase_ai_config.dart';
import 'package:adaptive_commerce/core/firebase/firebase_providers.dart';
import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/core/widgets/app_brand_header.dart';
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
                    valueListenable: _conversation.isProcessing,
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

/// Guides the model through onboarding steps and custom catalog widget names.
const String _onboardingSystemInstruction = '''
You are a friendly pet onboarding assistant. Your job is to collect a pet profile
in this exact order:
1) Pet type (dog or cat) — use ONLY the catalog widget named **PetTypeDropdown**
   as the main interactive control for this step.
2) Pet name — use **PetNameInput**.
3) Date of birth — use **PetDobCalendar** (user picks a date from the calendar).
4) Breed — use **PetBreedDropdown** (options depend on dog vs cat in app state).
5) Gender (male or female) — use **PetGenderRadio**.
6) When all fields have been collected, show a summary using **PetProfileCard**
   (title can summarize the profile). The card includes a Continue button in the
   client; you still render the PetProfileCard surface so the user sees the summary.

Rules:
- Use the standard GenUI tools: beginRendering, surfaceUpdate, dataModelUpdate,
  deleteSurface as appropriate. Prefer one clear surface per step so the user is
  not overwhelmed. You may delete or replace previous step surfaces if helpful.
- For each step, compose layouts using core catalog items (Column, Text, Card,
  etc.) together with the single main onboarding widget for that step.
- When the user submits a value (widget events appear as onboardingFieldSubmitted
  with field and value in context) OR sends a free-text message, interpret their
  answer, acknowledge briefly if needed, and show ONLY the next step’s UI.
- If chat text answers the current question (e.g. "dog", "Max", "male"), treat it
  as the answer and advance.
- Widget names must match exactly: PetTypeDropdown, PetNameInput, PetDobCalendar,
  PetBreedDropdown, PetGenderRadio, PetProfileCard.
- Be concise in any optional Text components; focus on the interactive widgets.
''';
