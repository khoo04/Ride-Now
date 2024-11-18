import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/auto_complete_suggestion_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/widgets/ride_input_field.dart';

class RideAutoCompleteSearchField extends StatefulWidget {
  const RideAutoCompleteSearchField(
      {super.key, required this.labelText, required this.controller});
  final String labelText;
  final TextEditingController controller;

  @override
  State<RideAutoCompleteSearchField> createState() =>
      _RideAutoCompleteSearchFieldState();
}

class _RideAutoCompleteSearchFieldState
    extends State<RideAutoCompleteSearchField> {
  List<AutoCompletePrediction> predictions = [];
  final SuggestionsController<AutoCompletePrediction> suggestionsController =
      SuggestionsController<AutoCompletePrediction>();
  bool isSearching = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<AutoCompletePrediction>?> _onSearchChanged(
      BuildContext context, String query) async {
    if (query.isNotEmpty) {
      // Set debounce for the search to avoid making requests too frequently
      if (isSearching) {
        final state = context.read<AutoCompleteSuggestionCubit>().state;
        return state is AutoCompleteSuggestionSuccess ? state.predictions : [];
      } else {
        isSearching = true;
        Future.delayed(const Duration(seconds: 3), () {
          isSearching = false;
        });
        await context.read<AutoCompleteSuggestionCubit>().searchLocation(query);
        final state = context.read<AutoCompleteSuggestionCubit>().state;

        return state is AutoCompleteSuggestionSuccess ? state.predictions : [];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutoCompleteSuggestionCubit,
        AutoCompleteSuggestionState>(
      builder: (context, state) {
        return TypeAheadField<AutoCompletePrediction>(
          controller: widget.controller,
          suggestionsCallback: (search) => _onSearchChanged(context, search),
          builder: (context, controller, focusNode) {
            return RideInputField(
                labelText: widget.labelText,
                controller: controller,
                focusNode: focusNode);
          },
          itemBuilder: (context, predictions) {
            return ListTile(
              title: Text(predictions.structuredFormatting!.mainText!),
              subtitle: Text(predictions.structuredFormatting!.secondaryText!),
              onTap: () {
                widget.controller.text = predictions.description!;
                suggestionsController.close();
              },
            );
          },
          hideOnSelect: true,
          suggestionsController: suggestionsController,
          onSelected: (selectedOption) {
            eLog(selectedOption);
            eLog("Called");
          },
        );
      },
    );
  }

//   Autocomplete<AutoCompletePrediction> _buildAutoComplete(AutoCompleteSuggestionState state) {
//     return Autocomplete<AutoCompletePrediction>(
//         optionsBuilder: (TextEditingValue textEditingValue) {
//           if (textEditingValue.text.isEmpty) {
//             return List.empty();
//           } else {
//             if (state is AutoCompleteSuggestionLoading) {
//               return List.empty();
//             } else {
//               return predictions;
//             }
//           }
//         },
//         fieldViewBuilder: (BuildContext context,
//             TextEditingController textEditingController,
//             FocusNode focusNode,
//             onFieldSubmitted) {
//           return RideInputField(
//             labelText: widget.labelText,
//             controller: textEditingController,
//             onFieldSubmitted: (String value) {
//               onFieldSubmitted();
//             },
//             focusNode: focusNode,
//             onChanged: (value) => _onSearchChanged(context, value),
//           );
//         },
//         optionsViewBuilder: (BuildContext context, onSelected, options) {
//           eLog(options);
//           return Align(
//             alignment: Alignment.topLeft,
//             child: Material(
//               color: Colors.white,
//               elevation: 4.0,
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   maxHeight: 200,
//                   maxWidth: MediaQuery.of(context).size.width - 36,
//                 ),
//                 child: state is AutoCompleteSuggestionLoading
//                     ? const Center(
//                         child: CircularProgressIndicator(
//                           color: AppPallete.primaryColor,
//                         ),
//                       )
//                     : options.isEmpty
//                         ? const Center(
//                             child: Text('No suggestions found'),
//                           )
//                         : ListView.separated(
//                             shrinkWrap: true,
//                             itemCount: options.length,
//                             separatorBuilder: (context, index) =>
//                                 const Divider(height: 1),
//                             itemBuilder: (context, index) {
//                               final option = options.elementAt(index);
//                               return InkWell(
//                                 onTap: () => onSelected(option),
//                                 child: Container(
//                                   color: index == 0
//                                       ? Colors.grey[400]
//                                       : Colors.white,
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 12,
//                                     horizontal: 16,
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       const Icon(Icons.location_on_outlined),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               option.description!,
//                                               style: const TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//               ),
//             ),
//           );
//         },
//         onSelected: (selectedOption) {},
//         displayStringForOption: (option) => option.description!,
//       );
//   }
// }
}
