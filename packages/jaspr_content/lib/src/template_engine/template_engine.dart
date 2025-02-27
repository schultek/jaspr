import '../page.dart';

abstract class TemplateEngine {
  Future<void> render(Page page);
}
