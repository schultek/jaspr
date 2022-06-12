
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/bootstrap.dart';
import 'package:jaspr_ui/core.dart';

const image1 =
    'https://media.istockphoto.com/photos/abstract-wavy-object-picture-id1198271727?b=1&k=20&m=1198271727&s=170667a&w=0&h=b626WM5c-lq9g_yGyD0vgufb4LQRX9UgYNWPaNUVses=';
const image2 =
    'https://media.istockphoto.com/photos/colorful-background-picture-id1280385511?b=1&k=20&m=1280385511&s=170667a&w=0&h=4-KMkIqgyw2gTBMTBbYZVZoidwRsWZzr3q0xyUDYhas=';
const image3 =
    'https://media.istockphoto.com/photos/abstract-technical-surface-picture-id1176400518?b=1&k=20&m=1176400518&s=170667a&w=0&h=iVjcx383dZqcTKXgKA-Y4l1npVns4fmeyrZMoSWICF8=';

class CarouselPage extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DivElement(
      classes: ['container', 'pt-5'],
      child: DivElement(
        children: [
          Header("Carousel test page:", size: HeaderSize.h1),
          Section(
            title: "Simple carousel",
            child: Carousel(
              items: [
                CarouselImage(image: Image(source: image1), label: 'Slide 1', isActive: true, interval: 1000),
                CarouselImage(image: Image(source: image2), label: 'Slide 2', interval: 1000),
                CarouselImage(image: Image(source: image3), label: 'Slide 3', interval: 1000),
              ],
            ),
          ),
          Section(
            title: "With control buttons",
            child: Carousel(
              enableControl: true,
              items: [
                CarouselImage(image: Image(source: image1), label: 'Slide 1', isActive: true),
                CarouselImage(image: Image(source: image2), label: 'Slide 2'),
                CarouselImage(image: Image(source: image3), label: 'Slide 3'),
              ],
            ),
          ),
          Section(
            title: "With indicators",
            child: Carousel(
              enableControl: true,
              enableIndicator: true,
              items: [
                CarouselImage(image: Image(source: image1), label: 'Slide 1', isActive: true),
                CarouselImage(image: Image(source: image2), label: 'Slide 2'),
                CarouselImage(image: Image(source: image3), label: 'Slide 3'),
              ],
            ),
          ),
          Section(
            title: "With captions",
            child: Carousel(
              enableControl: true,
              enableIndicator: true,
              items: [
                CarouselImage(
                  isActive: true,
                  image: Image(source: image1),
                  label: 'Slide 1',
                  caption: Caption(
                    title: Header('First slide label', size: HeaderSize.h4),
                    description: Paragraph("Some representative placeholder content for the first slide."),
                  ),
                ),
                CarouselImage(
                  image: Image(source: image2),
                  label: 'Slide 2',
                  caption: Caption(
                    title: Header('Second slide label', size: HeaderSize.h4),
                    description: Paragraph("Some representative placeholder content for the second slide."),
                  ),
                ),
                CarouselImage(
                  image: Image(source: image3),
                  label: 'Slide 3',
                  caption: Caption(
                    title: Header('Third slide label', size: HeaderSize.h4),
                    description: Paragraph("Some representative placeholder content for the third slide."),
                  ),
                ),
              ],
            ),
          ),
          Section(
            title: "Crossfade",
            child: Carousel(
              enableControl: true,
              enableIndicator: true,
              transition: CarouselTransition.fade,
              items: [
                CarouselImage(image: Image(source: image1), label: 'Slide 1', isActive: true),
                CarouselImage(image: Image(source: image2), label: 'Slide 2'),
                CarouselImage(image: Image(source: image3), label: 'Slide 3'),
              ],
            ),
          ),
          Section(
            title: "Individual item interval",
            child: Carousel(
              enableControl: true,
              enableIndicator: true,
              items: [
                CarouselImage(image: Image(source: image1), label: 'Slide 1', isActive: true, interval: 10000),
                CarouselImage(image: Image(source: image2), label: 'Slide 2', interval: 2000),
                CarouselImage(image: Image(source: image3), label: 'Slide 3'),
              ],
            ),
          ),
          Section(
            title: "Dark variant",
            child: Carousel(
              enableControl: true,
              enableIndicator: true,
              dark: true,
              items: [
                CarouselImage(image: Image(source: image1), label: 'Slide 1', isActive: true),
                CarouselImage(image: Image(source: image2), label: 'Slide 2'),
                CarouselImage(image: Image(source: image3), label: 'Slide 3'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Section extends StatelessComponent {
  final Component child;
  final String title;

  Section({required this.child, required this.title});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Header(title, size: HeaderSize.h3);
    yield DivElement(
      classes: ['mt-4', 'mb-4', 'pb-4', 'w-50'],
      child: child,
    );
  }
}
