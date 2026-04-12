import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inksight/bootstrap.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env.staging');
  await bootstrap();
}
