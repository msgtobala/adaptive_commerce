import 'dart:async';

import 'package:adaptive_commerce/core/firebase/firebase_ai_config.dart';
import 'package:adaptive_commerce/core/firebase/firebase_providers.dart';
import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/features/food/pet_profile_prompt.dart';
import 'package:adaptive_commerce/features/onboarding/pet_profile.dart';
import 'package:adaptive_commerce/features/onboarding/pet_profile_provider.dart';
import 'package:adaptive_commerce/features/vet/catalog/vet_catalog.dart';
import 'package:adaptive_commerce/features/vet/tools/vet_places_tool.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:firebase_ai/firebase_ai.dart' as firebase_ai;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';

import 'package:adaptive_commerce/core/widgets/shell_prompt_bar.dart';

/// Veterinary assistant: GenUI + Firebase AI (custom veterinary catalog widgets).
class VetPage extends ConsumerStatefulWidget {
  const VetPage({super.key});

  @override
  ConsumerState<VetPage> createState() => _VetPageState();
}

class _VetPageState extends ConsumerState<VetPage> {
  late final GenUiConversation _conversation;
  final List<String> _surfaceIds = [];
  bool _didBootstrap = false;

  @override
  void initState() {
    super.initState();

    final catalog = vetCatalog;
    final firebaseAI = ref.read(firebaseAIProvider);
    final processor = A2uiMessageProcessor(catalogs: [catalog]);

    final contentGenerator = FirebaseAiContentGenerator(
      catalog: catalog,
      systemInstruction: _vetSystemInstruction,
      additionalTools: [
        createVetPlacesTool(),
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
            vetTabMessageWithProfile(
              profile,
              'Welcome the user to Veterinary. Render exactly one VetTopicAdvice '
              'with title "Veterinary" and summary inviting questions. '
              'Include exactly seven bullets with short example prompts: '
              'vaccination schedule, remedies for itching, remedies for lice, '
              'what to watch for, when to call vet, and "Find the nearest in RS Puram". '
              'Do not include any other widgets.',
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
        UserMessage.text(vetTabMessageWithProfile(profile, text)),
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
                AppStrings.navVeterinary,
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

String vetTabMessageWithProfile(PetProfile profile, String userQuestion) {
  // Reuse the shared pet-profile formatting from Food.
  return '${formatPetProfileForPrompt(profile)}\n\nUser question:\n$userQuestion';
}

const String _vetSystemInstruction = '''
You are Happy Paws’ Veterinary assistant. The user message always includes a
**Pet profile** block and a **User question**. Respect the profile (pet type,
age, breed, gender) for every answer.

Medical safety:
- Feeding and health advice is not a substitute for a veterinarian.
- If the user describes severe symptoms, breathing trouble, seizures, severe lethargy,
  uncontrolled bleeding, or rapidly worsening illness: advise to seek urgent veterinary care.

You MUST render exactly ONE primary catalog widget per response (do NOT render multiple).
Catalog widgets:
1. **VetVaccinationSchedule** — vaccination/shot schedule.
2. **VetRemediesAnswer** — itching/lice/remedies and when to see vet.
3. **VetNearestVetFinder** — nearest clinic search (e.g., "Find the nearest in RS Puram").
4. **VetTopicAdvice** — welcome + example prompts.

Routing rules (decide which widget to render):
- If user asks for vaccination schedule or vaccines/shots: render VetVaccinationSchedule.
- If user asks "itching", "lice", "fleas", "skin parasites": render VetRemediesAnswer.
- If user asks "nearest", "RS Puram", "clinic near", "vet near": render VetNearestVetFinder.
- Otherwise (welcome/initial): render VetTopicAdvice.

Widget field requirements:

**VetVaccinationSchedule**
- title: short.
- summary: 1-2 sentences tailored to the pet profile.
- schedule: list of rows; each row MUST include:
  - ageBand (e.g., "6-8 weeks", "12 weeks", "1 year", etc.)
  - vaccine (e.g., "DHPP / core vaccines", "Rabies", etc.)
  - timing (short, e.g., "every 3-4 weeks until complete")
  - notes (short, optional in schema)
- safetyNote: optional, but prefer a sentence to consult vet schedule for local variants.
- whenToCallVet: 2-4 bullets like "If your pet has fever or is unwell, postpone..."

**VetRemediesAnswer**
- title: short.
- suspectedCondition: based on the user query (e.g., "itching from irritation/parasites").
- homeCare: 3-6 safe at-home steps (grooming, bathing guidance, environment cleaning).
- treatmentOptions: 2-5 options to discuss with vet (e.g., vet-recommended anti-parasite plan).
- redFlags: 4-7 urgent signs to seek care.
- whenToSeeVetNow: 2-4 immediate seek-care items.
- noteToConsult: 1 short line reminding not to self-prescribe meds.

**VetNearestVetFinder**
- title: short.
- query: the user location query (e.g., "RS Puram").
- places: list of 3-5 vet clinic cards in/near the requested area.
  Each place MUST include:
  - placeName
  - address
  - phone (can be empty string if unknown)
  - mapUrl and/or websiteUrl (prefer mapUrl when possible, must be https)
- mapSearchUrl: optional fallback; can be a valid `https://` Google Maps search URL.
- shortAnswer: 1-2 sentences explaining you cannot guarantee exact distance without live data.
- tips: 2-5 tips (call ahead, ask about availability, bring records).
- urgentSigns: 3-5 urgent signs where you should go urgently.

**search_nearest_vets** (custom tool) — MUST be called for VetNearestVetFinder.
- Pass `area_query` derived from the user's request + pet profile (when relevant).
- The tool returns `places[]`; you MUST copy those fields into `VetNearestVetFinder.places[]`.
- If the tool returns an error or an empty `places[]`, you MUST set `VetNearestVetFinder.places` to an empty list.
  In that case, rely on `mapSearchUrl` fallback only (do NOT fabricate clinics).

**VetTopicAdvice**
- title: "Veterinary"
- summary: welcome + what you can help with.
- bullets: exactly 7 example prompts.

GenUI protocol:
- Create or update surfaces with beginRendering, surfaceUpdate, and catalog widgets only
  from this Veterinary catalog.
- Prefer one new surface per user turn.
- When done with UI for the turn, call provideFinalOutput with a short summary string.
''';
