import '../../../server.dart';

class RawText extends Component {
  const RawText(this.text, {super.key});

  final String text;

  @override
  Element createElement() => RawTextElement(this);
}

class RawTextElement extends LeafRenderObjectElement {
  RawTextElement(super.component);

  @override
  void updateRenderObject() {
    (renderObject as MarkupRenderObject).updateText((component as RawText).text, true);
  }
}
