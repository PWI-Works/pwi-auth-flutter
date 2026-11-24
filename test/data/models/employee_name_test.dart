import 'package:flutter_test/flutter_test.dart';
import 'package:pwi_auth/data/models/employee.dart';

Employee _employee(String preferredName,
        [Map<String, dynamic> fields = const {}]) =>
    Employee.fromJson({
      'id': 'employee-1',
      'firstName': 'LegalFirst',
      'lastName': 'LegalLast',
      'preferredName': preferredName,
      'workEmail': 'employee@example.com',
      'mobile': '',
      'fullNameByLastname': 'LegalLast, LegalFirst',
      'seniorityString': '',
      'jobTitleString': '',
      'departmentString': '',
      'employmentStatus': 'Active',
      ...fields,
    });

void main() {
  test('suffix comes from the employee field and survives copying', () {
    final employee = _employee('John Smith', {'suffix': 'III'});
    expect(employee.suffix, 'III');
    expect(employee.copyWith().suffix, 'III');
    expect(_employee('John Smith, Jr.', {'suffix': null}).suffix, isEmpty);
  });

  for (final (name, first, middle, initials) in [
    ('John Smith', 'John', '', 'JS'),
    ('John Paul Smith', 'John', 'Paul', 'JS'),
    ('John Paul James Smith, Jr.', 'John', 'Paul James', 'JS'),
    ('John Smith, Jr', 'John', '', 'JS'),
    ('  John\t Paul  James\nSmith ,  Jr.  ', 'John', 'Paul James', 'JS'),
    ('John, Jr.', 'John', '', 'JJ'),
    ('John', 'John', '', 'JJ'),
    ('John Smith,  ', 'John', '', 'JS'),
    ('John Smith, Jr., III', 'John', '', 'JS'),
    ('', '', '', ''),
    (' \t\n ', '', '', ''),
    (' , Jr. ', '', '', ''),
  ]) {
    test('preferred name helpers for ${name.replaceAll('\n', r'\n')}', () {
      final employee = _employee(name);

      expect(employee.preferredFirstName, first);
      expect(employee.middleName, middle);
      expect(employee.suffix, isEmpty);
      expect(employee.initials, initials);
      expect(employee.preferredName, name);
      expect(employee.firstName, 'LegalFirst');
      expect(employee.lastName, 'LegalLast');
      expect(employee.toJson(), {'activeDirectoryProcessingStatus': null});
    });
  }
}
