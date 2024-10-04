import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:zuriel/tools/tools.dart';


//Dropdown features
// - label
// - width
// - height
// - value
// - onChanged  ss
// - items
// - has search box
// - has subtitle
// - close on select
class DefaultDropdown extends StatefulWidget {
  final List<DefaultMenuItem> items;
  final ValueChanged<DefaultMenuItem>? onChanged;
  final int? valueId;
  final String? valueAdditionalId;
  final double? width;
  final double? height;
  final String? label;
  final bool hasSearchBox;

  const DefaultDropdown(
      {super.key,
      required this.items,
      this.onChanged,
      this.valueId,
      this.valueAdditionalId,
      this.hasSearchBox = false,
      this.label,
      this.width,
      this.height});

  @override
  State<DefaultDropdown> createState() => _DefaultDropdownState();
}

class _DefaultDropdownState extends State<DefaultDropdown> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton2<DefaultMenuItem>(
        value: widget.valueId != null
            ? widget.items.firstWhereOrNull(
                (element) => element.id == widget.valueId,
              )
            : widget.valueAdditionalId != null
                ? widget.items.firstWhereOrNull(
                    (element) =>
                        element.additionalId == widget.valueAdditionalId,
                  )
                : null,
        isExpanded: true,
        dropdownSearchData: widget.hasSearchBox
            ? DropdownSearchData(
                searchController: searchController,
                searchInnerWidgetHeight: 48,
                searchInnerWidget: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                  child: DefaultTextField(
                      width: double.infinity,
                      label: "Search",
                      controller: searchController),
                ),
                searchMatchFn: (item, searchValue) {
                  bool found = false;
                  if (item.value?.title
                          .toLowerCase()
                          .contains(searchValue.toLowerCase()) ??
                      false) {
                    found = true;
                  } else {
                    if (item.value?.subtitle
                            ?.toLowerCase()
                            .contains(searchValue.toLowerCase()) ??
                        false) {
                      found = true;
                    }
                  }
                  return found;
                },
              )
            : null,
        dropdownStyleData: DropdownStyleData(
          offset: const Offset(0, -12),
          maxHeight: widget.hasSearchBox ? 300 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.0),
            border: Border.all(color: Colors.grey[400]!),
          ),
        ),
        buttonStyleData: ButtonStyleData(
          decoration: BoxDecoration(
            color: widget.onChanged == null ? Colors.grey[200] : null,
            borderRadius: BorderRadius.circular(0.0),
            border: Border.all(color: Colors.grey[400]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 48,
          width: widget.width ?? 200,
        ),
        hint: widget.label != null
            ? Text(
                widget.label!,
                style: const TextStyle(color: Colors.grey),
              )
            : null,
        menuItemStyleData: MenuItemStyleData(
          selectedMenuItemBuilder: (context, child) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: child,
            );
          },
        ),
        underline: const SizedBox(),
        selectedItemBuilder: (context) {
          return widget.items
              .map((e) => SizedBox(
                    width: (widget.width ?? 200) / .5,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                          text: TextSpan(children: [
                            if (widget.label != null)
                              TextSpan(
                                  text: "${widget.label}\n",
                                  style: const TextStyle(color: Colors.grey)),
                            TextSpan(
                                text:
                                    "${e.title}",
                                style: Theme.of(context).textTheme.bodyLarge),
                            if (e.subtitle != null)
                              TextSpan(
                                  text: " / ${e.subtitle}",
                                  style: const TextStyle(color: Colors.grey)),
                          ])),
                    ),
                  ))
              .toList();
        },
        items: getItems(),
        onChanged: widget.onChanged == null
            ? null
            : (value) {
                if (value != null) {
                  widget.onChanged?.call(value);
                }
              });
  }

  List<DropdownMenuItem<DefaultMenuItem>> getItems() {
    return widget.items.map<DropdownMenuItem<DefaultMenuItem>>((e) {
      return DropdownMenuItem<DefaultMenuItem>(
        value: e,
        child: SpacedColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${e.title}",
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            if (e.subtitle != null)
              Text(e.subtitle!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis),
          ],
        ),
      );
    }).toList();
  }
}

final class DefaultMenuItem extends Equatable {
  final int id;
  final String? additionalId;
  final String title;
  final String? subtitle;

  const DefaultMenuItem(
      {required this.id,
      required this.title,
      this.subtitle,
      this.additionalId});

  @override
  List<Object?> get props => [id, title, subtitle, additionalId];
}
