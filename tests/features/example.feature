Feature: Example of Testinfra BDD
  Give an example of all the possible Given, When and Then steps.

  Scenario: Skip Tests if Host is Windoze
    Given the host with URL "docker://sut" is ready within 10 seconds
    # The system property can be one of:
    #   - type (e.g. linux).
    #   - distribution (e.g. debian).
    #   - release (e.g. 11).
    #   - codename (e.g. bullseye).
    #   - arch (e.g. x86_64).
    #   - hostname (e.g. sut).
    #   - connection_type (e.g. docker or ssh).
    When the system property type is not Windoze skip tests

  Scenario Outline: Test for Absent Resources
    Given the host with URL "docker://sut" is ready within 10 seconds
    When the <resource_type> is "foo"
    Then the <resource_type> is absent
    And the <resource_type> state is absent # Alternative method.
    Examples:
      | resource_type |
      | user          |
      | group         |
      | package       |
      | file          |
      | pip package   |

  Scenario: User Checks
    Given the host with URL "docker://sut" is ready
    When the user is "ntp"
    Then the user is present
    And the user state is present # Alternative method of checking the state of a resource.
    And the user group is ntp
    And the user uid is 101
    And the user gid is 101
    And the user home is /nonexistent
    And the user shell is /usr/sbin/nologin

  Scenario: File Checks
    Given the host with URL "docker://sut" is ready
    When the file is /etc/ntp.conf
    # Expected state can be present or absent.
    Then the file is present
    # Alternative method of checking the state of a resource.
    And the file state is present
    # Valid types to check for are file, directory, pipe, socket or symlink.
    And the file type is file
    And the file owner is ntp
    And the file group is ntp
    And the file contents contains "debian.pool.ntp"
    And the file contents contains the regex ".*pool [0-9].debian.pool.ntp.org iburst"
    # The expected mode must be specified as an octal.
    And the file mode is 0o544

  Scenario: Group Checks
    Given the host with URL "docker://sut" is ready
    When the group is "ntp"
    # Can check if the group is present or absent.
    Then the group is present
    # Alternative method of checking the state of a resource.
    And the group state is present
    And the group gid is 101

  Scenario: Running Commands
    Given the host with URL "docker://sut" is ready
    When the command is "ntpq -np"
    Then the command return code is 0
    And the command "ntpq" exists in path
    And the command stdout contains "remote"

  Scenario: System Package
    Given the host with URL "docker://sut" is ready
    When the package is ntp
    # Can check if the package is absent, present or installed.
    Then the package is installed

  Scenario: Python Package
    Given the host with URL "docker://sut" is ready
    When the pip package is testinfra-bdd
    # Can check if the package is absent or present.
    Then the pip package is present
    And the pip package version is 0.3.0
    # Check that installed packages have compatible dependencies.
    And the pip check is OK

  Scenario Outline: Service Checks
    Given the host with URL "docker://sut" is ready
    When the service is <service>
    Then the service is <running_state>
    And the service is <enabled_state>
    Examples:
      | service | running_state | enabled_state |
      | ntp     | running       | enabled       |
      | named   | not running   | not enabled   |

  Scenario Outline: Test Pip Packages are Latest Versions
    Given the host with URL "docker://sut" is ready
    When the pip package is <pip_package>
    Then the pip package is present
    And the pip package is latest
    Examples:
      | pip_package      |
      | pytest-bdd       |
      | pytest-testinfra |
      | testinfra-bdd    |

  Scenario: Check Java is Installed in the Path
    Given the host with URL "docker://java11" is ready within 10 seconds
    Then the command "java" exists in path

  Scenario: Check Java 11 is Installed
    Given the host with URL "docker://java11" is ready
    When the command is "java -version"
    And the package is java-11-amazon-corretto-devel
    Then the command stderr contains "Corretto-11"
    And the command stderr contains the regex "openjdk version \"11\\W[0-9]"
    And the command stdout is empty
    And the command return code is 0
    And the package is installed
