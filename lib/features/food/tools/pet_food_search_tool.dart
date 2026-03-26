import 'package:adaptive_commerce/core/config/logging_config.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart' as dsb;

/// Temporary hardcoded fallback tool while live web search is unstable.
DynamicAiTool<JsonMap> createPetFoodHardcodedSearchTool() {
  return DynamicAiTool<JsonMap>(
    name: 'search_web_for_pet_food',
    description:
        'Returns hardcoded pet food links and details for demo reliability.',
    parameters: dsb.S.object(
      properties: {
        'search_query': dsb.S.string(
          description: 'Natural language pet food query.',
        ),
      },
      required: ['search_query'],
    ),
    invokeFunction: (args) async {
      final query = args['search_query']?.toString().trim() ?? '';
      appLog.info('search_web_for_pet_food (hardcoded): $query');

      return {
        'results': <Object>[
          <String, Object?>{
            'product_name': 'Royal Canin Mini Puppy Dog Dry Food (800g)',
            'url':
                'https://supertails.com/products/royal-canin-mini-puppy-dry-food',
            'price': 'Rs 862',
            'rating': '4.5/5',
            'description':
                'Dry puppy food for small breeds with multiple pack sizes available.',
            'retailer': 'Supertails',
            'primary_ingredients':
                'Dehydrated poultry protein, rice, animal fats, maize, beet pulp, vegetable protein isolate.',
            'food_form': 'Dry Kibble',
            'size_options': <Object>['800g', '2kg', '4kg', '8kg', '16kg'],
            'current_price': 'Rs 3,793 (4kg)',
            'price_per_100g': 'Approx. Rs 94',
            'target_breed_size': 'Small (adult weight < 10kg)',
            'key_benefits': 'Immune support, high energy for active growth',
            'suitability': 'Up to 10 months old',
            'special_features': 'Tailored kibble for small jaws',
            'comparison_link_label': 'Supertails',
            'nutritional_analysis': <String, Object?>{
              'protein': '31%',
              'fat': '20%',
              'fiber': '1.4%',
              'ash': '7.7%',
            },
            'key_nutrients': <Object>[
              'Vitamin E',
              'DHA',
              'L-carnitine',
              'Prebiotics (FOS)',
            ],
          },
          <String, Object?>{
            'product_name': 'Royal Canin Mini Puppy Dog Wet Food (12x85g)',
            'url':
                'https://supertails.com/products/royal-canin-mini-puppy-wet-food',
            'price': 'Rs 1246',
            'rating': '4.3/5',
            'description':
                'Wet puppy food in gravy, suitable for mini breed puppies.',
            'retailer': 'Supertails',
            'primary_ingredients':
                'Meat and animal derivatives, cereals, derivatives of vegetable origin, oils and fats, minerals.',
            'food_form': 'Wet Food (Gravy)',
            'size_options': <Object>['12x85g', '24x85g', '36x85g', '48x85g'],
            'current_price': 'Rs 1,246 (12 x 85g)',
            'price_per_100g': 'Approx. Rs 122',
            'target_breed_size': 'Small (adult weight < 10kg)',
            'key_benefits': 'Easy digestion, immune system support',
            'suitability': 'Up to 10 months old',
            'special_features': 'High palatability for picky eaters',
            'comparison_link_label': 'Supertails',
            'nutritional_analysis': <String, Object?>{
              'protein': '8%',
              'fat': '6%',
              'fiber': '1%',
              'ash': '2%',
              'moisture': '79%',
            },
            'key_nutrients': <Object>[
              'Vitamin D3',
              'Iron',
              'Manganese',
              'Zinc',
              'Omega fatty acids',
            ],
          },
          <String, Object?>{
            'product_name': 'Farmina N&D Pumpkin (Dry)',
            'url': 'https://amzn.in/d/09uRjv8M',
            'price': 'Rs 2600',
            'rating': '4.4/5',
            'description':
                'Amazon short-link listing for Farmina dry puppy food; open the link for current seller and variant details.',
            'retailer': 'Amazon.in',
            'primary_ingredients':
                'Fresh boneless chicken (24%), dehydrated chicken (22%), pea starch, chicken fat, dried pumpkin (5%).',
            'food_form': 'Dry Kibble',
            'size_options': <Object>['2.5kg'],
            'current_price': 'Rs 2,569 (2.5kg)',
            'price_per_100g': 'Approx. Rs 102',
            'target_breed_size': 'Small',
            'key_benefits': 'Grain-free, anti-oxidant rich, anti-inflammatory',
            'suitability': 'Puppies (Mini/Small)',
            'special_features': 'No artificial preservatives, pumpkin-enriched',
            'comparison_link_label': 'Amazon',
            'nutritional_analysis': <String, Object?>{
              'protein': '30%',
              'fat': '18%',
              'fiber': '2.9%',
              'ash': '7%',
              'omega_6': '3.3%',
            },
            'key_nutrients': <Object>[
              'Vitamin A',
              'Vitamin C',
              'Vitamin E',
              'Beta-carotene',
              'Lutein',
              'Glucosamine',
            ],
          },
          <String, Object?>{
            'product_name': 'Pedigree Puppy Dry Dog Food Chicken & Milk (3kg)',
            'url': 'https://amzn.in/d/020cW27M',
            'price': 'Rs 662',
            'rating': '4.4/5',
            'description':
                'Complete and balanced dry food for puppies with chicken and milk.',
            'retailer': 'Amazon.in',
            'primary_ingredients':
                'Cereal & by-products, Chicken & by-products, Meat & by-products, Soybean meal, Milk powder.',
            'food_form': 'Dry Kibble',
            'size_options': <Object>['3kg', 'other sizes available'],
            'current_price': 'Rs 662 (3kg)',
            'price_per_100g': 'Approx. Rs 22',
            'target_breed_size': 'Medium / All sizes',
            'key_benefits': 'Bone health, digestion, muscle growth',
            'suitability': 'Puppies',
            'special_features': '37 essential nutrients',
            'comparison_link_label': 'Amazon',
            'nutritional_analysis': <String, Object?>{
              'protein': '24%',
              'fat': '10%',
              'fiber': '5%',
              'moisture': '12%',
            },
            'key_nutrients': <Object>[
              'Calcium',
              'Phosphorus',
              'Zinc',
              'Vitamin E',
              'Selenium',
            ],
          },
        ],
      };
    },
  );
}
