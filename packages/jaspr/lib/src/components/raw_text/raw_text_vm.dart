import '../../../server.dart';

class RawText extends Component {
  const RawText(this.text, {super.key});

  final String text;

  @override
  Element createElement() => RawTextElement(this);
}

class RawTextElement extends SingleChildRenderObjectElement {
  RawTextElement(super.component);

  @override
  Component? build() => null;

  @override
  void updateRenderObject() {
    (renderObject as MarkupRenderObject).updateText((component as RawText).text, true);
  }
}
