import 'package:jaspr/jaspr.dart';
import 'package:jaspr/ui.dart';

class FormExample extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Form(children: [
      TextField(label: "Login:", id: "login", value: "Admin"),
      LineBreak(),
      TextField(label: "Password:", hidden: true, id: "password", value: "testPasswd379"),
      LineBreak(),
      Paragraph(
        child: Text("Your favorite color:"),
        style: MultipleStyle(
          styles: [
            TextStyle(fontWeight: FontWeight.bolder),
            BoxStyle(padding: EdgeInsets.only(top: Pixels(25))),
          ],
        ),
      ),
      RadioButton(label: "Blue", group: "color", value: "blue"),
      LineBreak(),
      RadioButton(label: "Red", group: "color", value: "red", checked: true),
      LineBreak(),
      RadioButton(label: "Yellow", group: "color", value: "yellow"),
      LineBreak(),
      RadioButton(label: "Brown", group: "color", value: "brown"),
      LineBreak(),
      RadioButton(label: "Green", group: "color", value: "green"),
      LineBreak(),
      RadioButton(label: "Black", group: "color", value: "black"),
      Header(
        "Your favorite colors:",
        size: HeaderSize.h4,
        style: MultipleStyle(
          styles: [
            TextStyle(fontWeight: FontWeight.bolder),
            BoxStyle(padding: EdgeInsets.only(top: Pixels(25))),
          ],
        ),
      ),
      CheckboxButton(label: "Blue", group: "colors", value: "blue", checked: true),
      LineBreak(),
      CheckboxButton(label: "Red", group: "colors", value: "red"),
      LineBreak(),
      CheckboxButton(label: "Yellow", group: "colors", value: "yellow", checked: true),
      LineBreak(),
      CheckboxButton(label: "Brown", group: "colors", value: "brown"),
      LineBreak(),
      CheckboxButton(label: "Green", group: "colors", value: "green"),
      LineBreak(),
      CheckboxButton(label: "Black", group: "colors", value: "black", checked: true),
    ]);
  }
}
