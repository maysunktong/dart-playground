import 'package:command_runner/command_runner.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner();
  await runner.run(arguments);
}
