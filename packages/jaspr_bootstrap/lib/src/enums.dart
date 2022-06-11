enum Breakpoint {
  extraSmall(''),
  small('-sm'),
  medium('-md'),
  large('-lg'),
  extraExtraLarge('-xl'),
  extraLarge('-xxl'),
  fluid('-fluid');

  final String value;
  const Breakpoint(this.value);
}

enum TextColor {
  primary('text-primary'),
  secondary('text-secondary'),
  success('text-success'),
  danger('text-danger'),
  warning('text-warning'),
  info('text-info'),
  light('text-light'),
  dark('text-dark'),
  body('text-body'),
  muted('text-muted'),
  white('text-white'),
  black50('text-black-50'),
  white50('text-white-50');

  final String value;
  const TextColor(this.value);
}

enum BackgroundColor {
  primary('bg-primary'),
  secondary('bg-secondary'),
  success('bg-success'),
  danger('bg-danger'),
  warning('bg-warning'),
  info('bg-info'),
  light('bg-light'),
  dark('bg-dark'),
  white('bg-white'),
  transparent('bg-transparent');

  final String value;
  const BackgroundColor(this.value);
}

enum BorderColor {
  primary('border-primary'),
  secondary('border-secondary'),
  success('border-success'),
  danger('border-danger'),
  warning('border-warning'),
  info('border-info'),
  light('border-light'),
  dark('border-dark'),
  white('border-white');

  final String value;
  const BorderColor(this.value);
}

enum BorderRound {
  all('rounded'),
  left('rounded-start'),
  top('rounded-top'),
  right('rounded-end'),
  bottom('rounded-bottom'),
  circle('rounded-circle'),
  pill('rounded-pill');

  final String value;
  const BorderRound(this.value);
}

enum BorderRadius {
  r0('rounded-0'),
  r1('rounded-1'),
  r2('rounded-2'),
  r3('rounded-3'),
  r4('rounded-4'),
  r5('rounded-5');

  final String value;
  const BorderRadius(this.value);
}

enum BorderWidth {
  w1('border-1'),
  w2('border-2'),
  w3('border-3'),
  w4('border-4'),
  w5('border-5');

  final String value;
  const BorderWidth(this.value);
}

enum BorderOpacity {
  o100(''),
  o75('border-opacity-75'),
  o50('border-opacity-50'),
  o25('border-opacity-25'),
  o10('border-opacity-10');

  final String value;
  const BorderOpacity(this.value);
}

enum TextAlign {
  start('start'),
  end('end'),
  wrap('wrap'),
  npwrap('nowrap'),
  truncate('truncate'),
  split('break');

  final String value;
  const TextAlign(this.value);
}

enum FontWeight {
  bold,
  bolder,
  normal,
  light,
  lighter,
}

enum FontStyle {
  normal,
  italic,
}

enum TextDecoration {
  none('none'),
  underline('underline'),
  lineThrough('line-through'),
  ;
  final String value;
  const TextDecoration(this.value);
}

enum Width {
  h25('w-25'),
  h50('w50'),
  h75('w-75'),
  h100('w-100'),
  auto('auto'),
  max('mw-100'),
  ;
  final String value;
  const Width(this.value);
}

enum Height {
  h25('h-25'),
  h50('h50'),
  h75('h-75'),
  h100('h-100'),
  auto('auto'),
  max('mh-100'),
  ;
  final String value;
  const Height(this.value);
}

enum Align {
  baseline('baseline'),
  top('top'),
  middle('middle'),
  bottom('bottom'),
  textTop('text-top'),
  textBottom('text-bottom'),
  ;
  final String value;
  const Align(this.value);
}

enum Position {
  static('position-static'),
  relative('position-relative'),
  absolute('position-absolute'),
  fixed('position-fixed'),
  sticky('position-sticky'),
  fixedTop('fixed-top'),
  fixedBottom('fixed-bottom'),
  stickyTop('sticky-top'),
  ;
  final String value;
  const Position(this.value);
}

enum Overflow { auto, hidden, visible, scroll }

enum Shadow {
  small('shadow-sm'),
  normal('shadow'),
  large('shadow-lg'),
  none('shadow-none'),
  ;
  final String value;
  const Shadow(this.value);
}

enum Space {
  s1('1'),
  s2('2'),
  s3('3'),
  s4('4'),
  s5('5'),
  auto('auto'),
  ;
  final String value;
  const Space(this.value);
}

enum Padding {
  top('pt'),
  bottom('pb'),
  left('ps'),
  right('pe'),
  horizontal('px'),
  vertical('py'),
  ;
  final String value;
  const Padding(this.value);
}

enum Margin {
  top('mt'),
  bottom('mb'),
  left('ms'),
  right('me'),
  horizontal('mx'),
  vertical('my'),
  ;
  final String value;
  const Margin(this.value);
}

enum ColumnSpace {
  auto('auto'),
  s1('1'),
  s2('2'),
  s3('3'),
  s4('4'),
  s5('5'),
  s6('6'),
  s7('7'),
  s8('8'),
  s9('9'),
  s10('10'),
  s11('11'),
  s12('12'),
  ;
  final String value;
  const ColumnSpace(this.value);
}
