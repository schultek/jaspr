import 'package:jaspr/jaspr.dart';

class Icon extends StatelessComponent {
  const Icon(this.name, {this.size, super.key});

  final String name;
  final Unit? size;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (name == 'jasper') {
      yield img(src: 'images/jasper_icon.png', alt: 'jasper-icon', styles: Styles(height: size ?? 1.2.em));
      return;
    } else if (name == 'dart') {
      yield img(src: 'images/dart_icon.png', alt: 'dart-icon', styles: Styles(height: size ?? 1.2.em));
      return;
    }
    yield i(classes: 'icon-$name', styles: Styles(fontSize: size ?? 1.2.em), []);
  }

  @css
  static List<StyleRule> get styles => [
        css('[class^=icon-custom-]').styles(
          width: 1.em,
          height: 1.em,
          color: Color.inherit,
          raw: {
            '-webkit-mask': 'var(--icon) no-repeat',
            'mask': 'var(--icon) no-repeat',
            '-webkit-mask-size': '100% 100%',
            'mask-size': '100% 100%',
            'background-color': 'currentColor',
          },
        ),
        css('.icon-custom-discord').styles(raw: {'--icon': 'url("$discordIcon")'}),
        css('.icon-custom-github').styles(raw: {'--icon': 'url("$githubIcon")'}),
        css('.icon-custom-jaspr').styles(raw: {'--icon': 'url("$jasprIcon")'}),
      ];
}

const githubIcon =
    r"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath d='M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12'/%3E%3C/svg%3E";
const discordIcon =
    r"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath d='M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028c.462-.63.874-1.295 1.226-1.994a.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418Z'/%3E%3C/svg%3E";
const jasprIcon =
    r"data:image/svg+xml,%3Csvg width='41' height='49' viewBox='0 0 41 49' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M15 39C15 39 19.2321 43.5674 23.2888 47L32.9625 36.5L35.5 38C36.5 33 32.9625 29.5248 32.9625 29.5248C37.3313 28.9007 36.3952 22.3475 36.3952 22.3475C34.2108 19.8511 33.8987 17.3546 34.2108 15.7943C34.5 14.5 34.0412 13.1572 33.5867 12.3617L36.3952 9.24113L38.5 9.5C38.5 4.5 30.4361 2 29.5 2C28.5638 2 26.0973 3.93617 25.4732 6.12057L17.9838 6.74468C17 -4 2.18791 7.87943 2.49998 11L4.99997 10L8.31006 14.5461C3.31715 18.2908 2.49997 26.5 2.49997 26.5L6.74978 25.7801C4.56538 30.1489 5.18949 35.1418 5.18949 35.1418L9 33.5C9.31206 37.5567 12.5 42 12.5 42L15 39Z' stroke='black' stroke-width='4' stroke-linejoin='round'/%3E%3Cpath d='M17.9838 6.74467C16.4235 6.74467 15.5 8 13 11C10.5 14 11.7427 13.6099 7.37387 15.1702' stroke='black' stroke-width='4' stroke-linejoin='round'/%3E%3Cpath d='M25.4732 6.12057C27.9696 6.74469 31.4023 8.61703 33.5866 12.3617' stroke='black' stroke-width='4' stroke-linejoin='round'/%3E%3Cpath d='M6.74979 25.7802C6.74979 25.7802 8.62213 22.3475 12.6789 20.4752C8.31007 22.3475 6.74979 25.7802 6.74979 25.7802Z' stroke='black' stroke-width='4' stroke-linejoin='round'/%3E%3Cpath d='M31.1907 22.0591C31.1907 22.0591 27.446 21.435 28.0701 24.2435C28.8329 27.6761 33.9992 26.1158 33.6872 23.9314C33.6872 22.0591 31.1907 22.0591 31.1907 22.0591Z' fill='black'/%3E%3Cpath d='M33.2746 29.5248C30.4661 29.5248 25 30 22 28C27.5 31.5 33 28.5 35.5 34.5C34.5 31 33.5 30.5 33.2746 29.5248Z' stroke='black' stroke-width='4' stroke-linejoin='round'/%3E%3C/svg%3E%0A";
