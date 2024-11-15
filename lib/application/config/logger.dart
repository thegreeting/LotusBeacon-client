import 'package:simple_logger/simple_logger.dart';

final _levelPrefixes = <Level, String>{
  Level.FINEST: '\x1b[90m👾 ',
  Level.FINER: '\x1b[90m👀 ',
  Level.FINE: '\x1b[90m🎾 ',
  Level.CONFIG: '\x1b[90m🐶 ',
  Level.INFO: '\x1b[37m👻 ',
  Level.WARNING: '\x1b[93m⚠️ ',
  Level.SEVERE: '\x1b[103m\x1b[31m‼️ ',
  Level.SHOUT: '\x1b[41m\x1b[93m😡 ',
};

final logger = SimpleLogger()
  ..mode = LoggerMode.log
  ..setLevel(
    Level.FINEST,
    includeCallerInfo: true,
  )
  ..formatter = (info) {
    const end = '\x1b[0m';

    return '${_levelPrefixes[info.level] ?? ''}'
        '${info.message} '
        '\x1b[90m[${info.callerFrame ?? 'caller info not available'}]$end'
        '$end';
  };
