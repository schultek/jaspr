part of 'document.dart';

class _FileDocument extends Document {
  const _FileDocument({
    this.name = 'index.html',
    this.attachTo = 'body',
    required this.child,
  }) : super._();

  final String name;
  final String attachTo;
  final Component child;

  @override
  State<Document> createState() => _FileDocumentState();

  @override
  Element createElement() => _DocumentElement(this);
}

class _FileDocumentState extends State<_FileDocument> {
  @override
  void initState() {
    super.initState();
    (context.binding as DocumentBinding)._loadFile(component.name);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield component.child;
  }
}
