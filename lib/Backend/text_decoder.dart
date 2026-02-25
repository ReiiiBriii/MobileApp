
// For Reference Number (e.g. "Ref. No. 8038 145 800485" or standalone long number)
final RegExp _referenceWithLabelRegex = RegExp(
  r'(?:ref(?:erence)?\s*(?:number|no\.?)?\s*[:\-\.]?\s*)([0-9][0-9\s]{5,})',
  caseSensitive: false,
);

// Fallback: any long digit sequence (often the reference at the bottom of the receipt/SMS)
final RegExp _referenceFallbackRegex = RegExp(
  r'\b\d[\d\s]{8,}\b',
  caseSensitive: false,
);

String normalizeText(String text) {
  return text
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('Refer ence', 'Reference')
      .replaceAll('Num ber', 'Number');
}

String? extractReference(String text) {
  final normalized = normalizeText(text);
  // 1) Try matching with explicit "Ref"/"Reference" label
  final withLabel = _referenceWithLabelRegex.firstMatch(normalized);
  if (withLabel != null) {
    final raw = withLabel.group(1) ?? '';
    return raw.replaceAll(RegExp(r'\D'), '');
  }

  // 2) Fallback: pick the LAST long digit sequence in the text
  final allFallbacks = _referenceFallbackRegex.allMatches(normalized).toList();
  if (allFallbacks.isEmpty) return null;

  final raw = allFallbacks.last.group(0) ?? '';
  return raw.replaceAll(RegExp(r'\D'), '');
}

//For Sender's and Receiver's number
Map<String, String>? extractTransferParties(String text) {
  final normalized = normalizeText(text);

  // Pattern 1: "Transfer from 09XXXXXXXXX to 09XXXXXXXXX"
  final transferRegex = RegExp(
    r'(?:[tT0]ransfer\s*(?:from)?\s*)((?:\+63|0)\s*9\d{2}\s*\d{3}\s*\d{4})\s*to\s*((?:\+63|0)\s*9\d{2}\s*\d{3}\s*\d{4})',
    caseSensitive: false,
  );

  RegExpMatch? match = transferRegex.firstMatch(normalized);
  String? senderRaw;
  String? receiverRaw;

  if (match != null) {
    senderRaw = match.group(1)!;
    receiverRaw = match.group(2)!;
  } else {
    // Pattern 2: SMS-style "You have received ... from NAME ... +639XXXXXXXXX"
    final smsRegex = RegExp(
      r'from\s+.+?\s*((?:\+63|0)\s*9\d{2}\s*\d{3}\s*\d{4})',
      caseSensitive: false,
    );
    match = smsRegex.firstMatch(normalized);
    if (match == null) return null;
    senderRaw = match.group(1)!;
    receiverRaw = null; // Receiver may not appear in SMS text
  }

  String cleanNumber(String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.startsWith('63') && digitsOnly.length == 12) {
      return '+$digitsOnly';
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('09')) {
      return digitsOnly;
    }

    return raw.trim();
  }

  return {
    'sender': cleanNumber(senderRaw),
    if (receiverRaw != null) 'receiver': cleanNumber(receiverRaw),
  };
}

// For Date & Time (with or without label, multiple formats)
final List<RegExp> _dateTimePatterns = [
  // e.g. "Date & Time Feb 24, 2026 8:59 PM" or "Feb 24, 2026 8:59 PM"
  RegExp(
    r'(?:date\s*(?:&|and)?\s*time\s*)?([A-Za-z]{3,9}\s+\d{1,2},\s*\d{4}\s+\d{1,2}:\d{2}(?::\d{2})?\s*(?:AM|PM|am|pm)?)',
    caseSensitive: false,
  ),
  // e.g. "21 February 2026 05:05:46 PM"
  RegExp(
    r'(?:date\s*(?:&|and)?\s*time\s*)?(\d{1,2}\s+[A-Za-z]{3,9}\s+\d{4}\s+\d{1,2}:\d{2}(?::\d{2})?\s*(?:AM|PM|am|pm)?)',
    caseSensitive: false,
  ),
  // e.g. "Today, 09:01 PM" or "Today 09:01 PM"
  RegExp(
    r'((?:today|yesterday)\s*,?\s*\d{1,2}:\d{2}(?::\d{2})?\s*(?:AM|PM|am|pm)?)',
    caseSensitive: false,
  ),
];

String? extractDateTime(String text) {
  final normalized = normalizeText(text);
  for (final pattern in _dateTimePatterns) {
    final match = pattern.firstMatch(normalized);
    if (match != null) {
      return match.group(1)?.trim();
    }
  }
  return null;
}

final RegExp amountRegex = RegExp(
  r'[-+]?\s*(?:₱|php)?\s*([\d,]+(?:\.\d{2}))',
  caseSensitive: false,
);

String? extractAmount(String text){
  final normalized = normalizeText(text);
  final match = amountRegex.firstMatch(normalized);
  if(match == null) return null;
  return match.group(1)?.trim();
}