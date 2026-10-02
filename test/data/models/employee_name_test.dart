import 'package:flutter_test/flutter_test.dart';
import 'package:pwi_auth/data/models/employee.dart';

Employee _employee(String preferredName) => Employee.fromJson({
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
    });

void main() {
  for (final (name, first, middle, suffix, initials) in [
    ('John Smith', 'John', '', '', 'JS'),
    ('John Paul Smith', 'John', 'Paul', '', 'JS'),
    ('John Paul James Smith, Jr.', 'John', 'Paul James', 'Jr.', 'JS'),
    ('John Smith, Jr', 'John', '', 'Jr', 'JS'),
    ('  John\t Paul  James\nSmith ,  Jr.  ', 'John', 'Paul James', 'Jr.', 'JS'),
    ('John, Jr.', 'John', '', 'Jr.', 'JJ'),
    ('John', 'John', '', '', 'JJ'),
    ('John Smith,  ', 'John', '', '', 'JS'),
    ('John Smith, Jr., III', 'John', '', 'Jr., III', 'JS'),
    ('', '', '', '', ''),
    (' \t\n ', '', '', '', ''),
    (' , Jr. ', '', '', 'Jr.', ''),
  ]) {
    test('preferred name helpers for ${name.replaceAll('\n', r'\n')}', () {
      final employee = _employee(name);

      expect(employee.preferredFirstName, first);
      expect(employee.middleName, middle);
      expect(employee.suffix, suffix);
      expect(employee.initials, initials);
      expect(employee.preferredName, name);
      expect(employee.firstName, 'LegalFirst');
      expect(employee.lastName, 'LegalLast');
      expect(employee.toJson(), {'activeDirectoryProcessingStatus': null});
    });
  }
}
