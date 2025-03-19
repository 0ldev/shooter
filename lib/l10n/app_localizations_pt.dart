// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Timer de Tiro';

  @override
  String get start => 'Iniciar';

  @override
  String get stop => 'Parar';

  @override
  String get reset => 'Reiniciar';

  @override
  String get settings => 'Configurações';

  @override
  String get micSensitivity => 'Sensibilidade do Microfone';

  @override
  String get language => 'Idioma';

  @override
  String get countdown => 'Contagem regressiva (segundos)';

  @override
  String get english => 'Inglês';

  @override
  String get portuguese => 'Português (Brasil)';

  @override
  String get shot => 'Tiro';

  @override
  String get drawTime => 'Tempo de Saque';

  @override
  String get shotTime => 'Tempo do Tiro';

  @override
  String get splitTime => 'Intervalo';

  @override
  String get ready => 'Pronto';

  @override
  String get set => 'Preparar';

  @override
  String get go => 'Já!';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get developedBy => 'Desenvolvido por Albert Katri';

  @override
  String get permissionDenied => 'Permissão do microfone negada';

  @override
  String get errorStartingMic => 'Erro ao iniciar o microfone';

  @override
  String get history => 'Histórico';

  @override
  String get noHistory => 'Sem histórico de treino disponível';

  @override
  String get sessionDetails => 'Detalhes da Sessão';

  @override
  String get date => 'Data';

  @override
  String get duration => 'Duração';

  @override
  String get totalDuration => 'Duração Total';

  @override
  String get shotCount => 'Número de Tiros';

  @override
  String get averageSplitTime => 'Tempo Médio de Intervalo';

  @override
  String get sessionSaved => 'Sessão de treino salva com sucesso';

  @override
  String get sessionDeleted => 'Sessão excluída';

  @override
  String get errorSavingSession => 'Erro ao salvar sessão de treino';

  @override
  String get errorOccurred => 'Ocorreu um erro';

  @override
  String get noShotsToSave => 'Não há tiros para salvar';

  @override
  String get saveSession => 'Salvar Sessão';

  @override
  String get clearShots => 'Limpar Tiros';

  @override
  String get shots => 'tiros';

  @override
  String get trainingMode => 'Modo de Treino';

  @override
  String get saveTrain => 'Treino com Salvamento';

  @override
  String get quickTrain => 'Treino Rápido';

  @override
  String get saveTrainDesc => 'Salve sessões para análise posterior';

  @override
  String get quickTrainDesc => 'Prática rápida sem salvar dados';

  @override
  String get noShotsRecorded => 'Nenhum tiro registrado';

  @override
  String get mustClearOrSaveBeforeStart => 'Por favor, salve ou limpe os tiros antes de iniciar uma nova sessão';
}
