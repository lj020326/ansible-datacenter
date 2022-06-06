
# Example 2: Unset variable 'test' from the initial 'cluster' group to validate if expected result occurs

On this test, unset `test` from `[cluster:vars]` in the ini inventory [hosts.ini](./hosts.ini):

```ini
;test="cluster"
ansible_group_priority=10
```

The expectation is that the variable set in the `override` group will win.
But it does not. Instead, `product1` wins:

```output
ansible -i hosts.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "product1"
}
```

It is not immediately intuitive why the `ansible_group_priority` does not result in the expected value.

The same results can be confirmed when you convert the same to a yaml inventory as [hosts.yml](./hosts.yml).

When querying variable `test` in [hosts.yml](./hosts.yml), the query results with the group 'product1' winning as the ini inventory example:

```output
ansible -i hosts.yml -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "product1"
}
```


## Conclusions/Next Steps

The [next example](../example3/README.md) will look to further into the group variable merge behavior.

