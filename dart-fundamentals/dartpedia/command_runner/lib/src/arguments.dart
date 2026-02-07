import 'dart:async';
import 'dart:collection';
import '../command_runner.dart';

// Enums are useful for representing a fixed set of possible values.
// flag (a boolean option) or a regular option (an option that takes a value)
enum OptionType { flag, option }

// The abstract keyword means that Command can't be instantiated directly. It serves as a blueprint for other classes.
abstract class Argument {
  String get name;
  String? get help;

  // In the case of flags, the default value is a bool.
  // In other options and commands, the default value is a String.
  // NB: flags are just Option objects that don't take arguments
  Object?
  get defaultValue; // defaultValue is of type Object? because it can be a bool (for flags) or a String.
  // valueHelp is an optional String to give a hint about the expected value.
  String? get valueHelp;
  // The usage getter will provide a string showing how to use the argument.
  String get usage;
}

// The Option class will represent command-line options like --verbose or --output=file.txt. It will inherit from your Argument class.
class Option extends Argument {
  Option(
    this.name, {
    required this.type,
    this.help,
    this.abbr,
    this.defaultValue,
    this.valueHelp,
  });

  @override
  final String name;

  final OptionType type;

  @override
  final String? help;

  final String? abbr;

  @override
  final Object? defaultValue;

  @override
  final String? valueHelp;

  @override
  String get usage {
    if (abbr != null) {
      return '-$abbr,--$name: $help';
    }

    return '--$name: $help';
  }
}

// The Command class will represent an executable action. Since it provides a template for other commands to follow, you'll declare it as abstract.

// The runner property is of type CommandRunner, which you will define later in command_runner_base.dart. To make Dart aware of this class, you must import its defining file. Add the following import to the top of command_runner/lib/src/arguments.dart:
abstract class Command extends Argument {
  @override
  String get name;

  String get description;

  bool get requiresArgument => false;

  late CommandRunner runner;

  @override
  String? help;

  @override
  String? defaultValue;

  @override
  String? valueHelp;

  final List<Option> _options = [];

  // This uses the UnmodifiableSetView class, which is part of Dart's core collection library. To use it, you must import that library.
  // Update the imports at the top of your file to include dart:collection
  UnmodifiableSetView<Option> get options =>
      UnmodifiableSetView(_options.toSet());

  // A flag is an [Option] that's treated as a boolean.
  void addFlag(String name, {String? help, String? abbr, String? valueHelp}) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: false,
        valueHelp: valueHelp,
        type: OptionType.flag,
      ),
    );
  }

  // An option is an [Option] that takes a value.
  void addOption(
    String name, {
    String? help,
    String? abbr,
    String? defaultValue,
    String? valueHelp,
  }) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: defaultValue,
        valueHelp: valueHelp,
        type: OptionType.option,
      ),
    );
  }

  FutureOr<Object?> run(ArgResults args);

  @override
  String get usage {
    return '$name:  $description';
  }
}

// Add this class to the end of the file
class ArgResults {
  Command? command;
  String? commandArg;
  Map<Option, Object?> options = {};

  // Returns true if the flag exists.
  bool flag(String name) {
    // Only check flags, because we're sure that flags are booleans.
    for (var option in options.keys.where(
      (option) => option.type == OptionType.flag,
    )) {
      if (option.name == name) {
        return options[option] as bool;
      }
    }
    return false;
  }

  bool hasOption(String name) {
    return options.keys.any((option) => option.name == name);
  }

  ({Option option, Object? input}) getOption(String name) {
    var mapEntry = options.entries.firstWhere(
      (entry) => entry.key.name == name || entry.key.abbr == name,
    );

    return (option: mapEntry.key, input: mapEntry.value);
  }
}
