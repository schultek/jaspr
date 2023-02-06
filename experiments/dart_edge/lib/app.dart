import 'package:jaspr/html.dart';
import 'package:vercel_edge/public/request.dart';

import 'button.dart';

class App extends StatelessComponent {
  App({required this.props});
  final IncomingRequestVercelProperties props;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World'),
    );

    yield ul([
      li([text('IP Adress: ${props.ipAddress}')]),
      li([text('City: ${props.city}')]),
      li([text('Country: ${props.country}')]),
      li([text('Region: ${props.region}')]),
      li([text('Country Region: ${props.countryRegion}')]),
      li([text('Latitude: ${props.latitude}')]),
      li([text('Longitude: ${props.longitude}')]),
    ]);
    yield div(id: 'button', [
      Button(),
    ]);
  }
}
