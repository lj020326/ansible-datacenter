# Simple bash testing framework

This is a simple set of scripts to let you write tests that run bash commands,
and report on any failures. Each test (or test of tests) is its own bash
script, which should be named `01-something-test.sh`. You can run each test
script individually, or run `./all_tests.sh` to go through each test in turn.

## Writing test scripts

See `01-test-test.sh` for an example. This script tests the test suite itself,
and it's a good idea to leave this in as your first set of tests.

The following is a minimal test script:

```shell
#!/bin/bash

# Load the testing framework
. ./testlib.sh

TEST_SUITE_NAME="Test something"

# Number of tests
TOTAL_TESTS=1

# Put your tests here
assert "Sample test" 'true'

# Print results
report

```

This contains several parts:

* A line to load the testing library
* Set the name of the test suite. This will be displayed in the report.
* Set the total number of tests. If this amount of tests aren't run, then the
  test suite will fail.
* The tests themselves
* A command to print the results at the end

### Test commands

There are 3 comands provided to 'run' tests:

* `assert "Test Name" "command"`
* `assert_ran_ok "Test Name"`
* `assert_not_ran_ok "Test Name"`

Each of these takes a test name as their first parameter.

The `assert_ran_ok` and `assert_not_ran_ok` commands both look at the return
value of the last command run; in other words the value of `$?`.

The `assert` command takes a second parameter, which is a command to run, and
will test the return value of that.

You can also use the `assert` command to run a bash test

Here are some examples:

```shell
# Some simple assert examples
assert "Make sure foo ran ok" foo
assert 'Test the value of $FOO' '[[ $FOO == "foo" ]]'
assert 'Make sure $FOO is set' '[[ -n $FOO ]]'

# More complex example of comparing command output
# You make the command output to 01-foo-test-1.out, and have the expected
# output in 01-foo-test-1.cmp. If you need to do multiple output tests for
# the same test script, then use ./01-foo-test-2.cmp and so on
OF_PREFIX="${0%.sh}" # Expands to './01-foo-test'
my_command | tee $OF_PREFIX-1.out
assert_ran_ok "my_command ran ok"
assert 'got the expected output from my_command' \
  'diff -u $OF_PREFIX-1.cmp $OF_PREFIX-1.out'

```

## Running tests

Either run the test script directly, or run `./all_tests.sh` to run all tests.

The test script will output a report that looks like the following:

```shell
====================================================================
Test suite: Test the testing framework
====================================================================
  1: PASS - true
  2: PASS - inverse
  3: PASS - [[ condition ]]
  4: PASS - [[ -n $SOME_VAR ]]
  5: PASS - [[ -z $BLANK_VAR ]]
  6: PASS - [[ -n $SOME_VAR ]] (double quotes)
  7: PASS - [[ -z $BLANK_VAR ]] (double quotes)
  8: PASS - assert_ran_ok on 'true'
  9: PASS - assert_not_ran_ok on 'false'
====================================================================
Number of tests run: 9

```

And the `all_tests.sh` script will additionally report at the end if any tests
failed.

If any tests fail (or you want to look anyway), all command output and test
commands run is available in `01-foo-test.log` (based on the name of your
test script).

Once you have finished running tests, `clean.sh` will remove any `.log` and
`.out` files generated during tests.

## Recommendations/best practices

* If you have multiple test scripts and find yourself repeating the same code
  to set up the tests, create a `test_setup.sh` script to contain any common
  code and helper functions, and source it from your other test scripts right
  after loading the test library.
* Any additional files you use for your tests should start with the same name
  as the test script, with a numerical suffix. The extension should describe
  the use of the file:
  * `01-foo-test-1.cmp` - Should contain expected command output to compare
    the actual output with.
  * `01-foo-test-1.in` - Sample input file to pass to a command.
  * `01-foo-test-1.out` - Actual command output generated when running tests.
* Stdout and stderr are redirected to `01-foo-test.log`, so you don't need to
  manually redirect them when running commands. In fact, doing so may hinder
  you should you need to look at why a test failed.
* The above also applies to diff commands. If you use diff -u, then when the
  test fails, you'll have a nice diff between the two files waiting for you in
  the log file.

## Reference

* https://github.com/mivok/bash_test
* 