enum PaymentMethod { credito, debito, pix, dinheiro, brinde }

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.credito => 'Crédito',
        PaymentMethod.debito => 'Débito',
        PaymentMethod.pix => 'Pix',
        PaymentMethod.dinheiro => 'Dinheiro',
    PaymentMethod.brinde => 'Brinde',
      };

  static PaymentMethod parse(String s) {
    switch (s.toLowerCase()) {
      case 'crédito':
      case 'credito':
        return PaymentMethod.credito;
      case 'débito':
      case 'debito':
        return PaymentMethod.debito;
      case 'pix':
        return PaymentMethod.pix;
      case 'dinheiro':
        return PaymentMethod.dinheiro;
      case 'brinde':
        return PaymentMethod.brinde;
      default:
        return PaymentMethod.pix;
    }
  }
}

enum ExpenseCategory { embalagens, materiais, utensilios, impressao, outros }

extension ExpenseCategoryX on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.embalagens => 'Embalagens',
        ExpenseCategory.materiais => 'Materiais',
        ExpenseCategory.utensilios => 'Utensílios',
        ExpenseCategory.impressao => 'Impressão',
        ExpenseCategory.outros => 'Outros',
      };

  static ExpenseCategory parse(String s) {
    switch (s.toLowerCase()) {
      case 'embalagens':
        return ExpenseCategory.embalagens;
      case 'materiais':
        return ExpenseCategory.materiais;
      case 'utensilios':
      case 'utensílios':
        return ExpenseCategory.utensilios;
      case 'impressao':
      case 'impressão':
        return ExpenseCategory.impressao;
      default:
        return ExpenseCategory.outros;
    }
  }
}
