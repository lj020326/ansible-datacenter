
# The subtlety of group_vars/ directory

Out of all Ansible nuances, variable precedence rules, and, specifically, `group_vars` is the hardest to understand and is the most confusing. I already wrote about those things, but yet again I found them fighting against intuition, so, I’ll rehearse the rules with concrete examples of corner cases.

I’ll use this doc as reference: [https://docs.ansible.com/ansible/latest/user\_guide/playbooks\_variables.html#understanding-variable-precedence](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#understanding-variable-precedence)

Everything I said here is related to _default_ configuration for Ansible, because you can mess up with priorities a lot from ansible.cfg.

## Group vars

Before things become mad, let’s start from sane part. There are hosts in Ansible. They are placed in ‘groups’ (and one host may be a member of few groups). hosts may have variables, associated with them. Groups may have variables, associated with them. They are called ‘group vars’.

## There are three sources of group vars

Now let’s raise the complexity bar. There are three different sources of group\_vars, and each group has different precedence depending on the name (‘all’ is weaker, normal group is stronger).

Group vars can be in:

-   `group_vars` directory near playbook. They are called ‘playbook group\_vars’.
-   `group_vars` directory near inventory file, or, if inventory is a directory, in the inventory directory. They are called ‘inventory group\_vars’.
-   group vars inside inventory file(s). They looks like this:

```yaml
foo:
  hosts:
    ...
  vars:
    somevar: 42

```

This ‘somevar’ inside ‘vars’ section of the inventory file is the thing. It’s called ‘inventory file or script group vars’. (yep, I’m totally miss ‘script’ part here, but it’s the thing too).

Even they all called ‘group vars’, they have very different ‘power’, or ‘precedence’. That’s the rule what to do if the same var appears in few places.

Initial rules somewhat simple:

Playbook may have `group_vars` directory, and content of that directory has precedence of is #**7** or #5 (it’s ‘5’ for ‘all’ and ‘7’ for all other groups).

Within our discussion about group vars, it’s the strongest.

If you have inventory in the same directory as your playbook, this directory is both inventory and playbook group\_vars, and it’s wins over itself (no issue here).

If you have inventory separated, it can have own group\_vars directory, and that directory is loosing to the group\_vars from playbooks directory.

```shell
.
├── group_vars
│   └── foo.yml
├── inv
│   ├── one
│   │   ├── group_vars
│   │   │   └── foo.yml
│   │   └── hosts.yml
│   └── two
│       └── hosts.yml
└── play.yml
```

In this scenario there is `./group_vars` (that’s playbook group vars), and there is `inv/one/group_vars` (that’s inventory ‘one’ group\_vars).

`./group_vars/foo.yml` is winning over every other group vars.

`./inv/one/group_vars` is #6 or #**4** in the precedence list. It looses to playbook level group vars, but winning over _inventory file or script group var._

Inventory file has the least precedence, # **3**.

Note, there is nothing about ‘all’ group here, but trust me, it’s loosing to normal (non-all) groups. (which is #_2.5_ in the list, it wins over role default and command line options, but loosing to everything else).

## Two inventories

Let’s raise complexity even further. It’s become really hard, but those subtleties are important.

If you don’t know, Ansible supports multiple inventories. It’s really useful for constructing stagings from production inventories (just replace IPs and you have your production on a separate set of servers) and for many other things. General idea is that every next inventory is winning over previous one.

But if you have two or more inventories, you need to be really careful with `group_vars`. Even if second inventory is winning over first one, it’s doing it according to precedence level. ‘Order for inventories’ works only within same precedence level. Higher precedence level wins over all other inventories disregarding the order.

## Over-complicated example

Let’s say we have two inventories, and each inventory has the same variable all possible places for group variables, and there are playbook group\_vars. Inventories called ‘one’ and ‘two’. There going to be two groups: ‘all’ (a special group), and ‘foo’ (just ‘a regular group’).

This is the file tree for the project:

```shell
.
├── group_vars
│   ├── all.yaml
│   └── foo.yaml
├── inv
│   ├── one
│   │   ├── group_vars
│   │   │   ├── all.yaml
│   │   │   └── foo.yaml
│   │   └── hosts.yaml
│   └── two
│       ├── group_vars
│       │   ├── all.yaml
│       │   └── foo.yaml
│       └── hosts.yaml
└── play.yaml

```

We are running our playbook like this:

`ansble-playbook -i inv/one -i inv/two play.yaml`

**Winning order (from loser to winner)**

-   `inv/one/hosts.yaml, all: vars`: it’s the ‘all’ group, it’s ‘inventory file’, and it’s first in the list.
-   `inv/two/hosts.yaml, all: vars`: it’s winning over previous, because it’s later in command line, but loosing to everything else.
-   `inv/one/hosts.yaml, foo: vars`: it’s winning other ‘all’ groups in inventory files, and it’s loosing to everything else.
-   `inv/two/hosts.yaml, foo: vars`: it’s winning other ‘all’ groups in inventory files, and it’s wining over the same in ‘one’, because it’s later in command line. Please note, that all inventory file vars loosing to ‘all’ in other categories. It’s unexpected. Deal with this.
-   `inv/one/group_vars/all.yaml`: it’s a group\_vars in the inventory and it’s winning over all group vars from ‘inventory files’ _(there are also host vars, but we are ignoring them for this article)._
-   `inv/one/group_vars/all.yaml`: winning over previous, because it’s later.
-   `group_vars/all.yaml`: That’s first playbook vars in the play. They are very strong. They win over all other “all’s”, and they win over group vars from inventory file completely (again, we are _ignoring host vars here_).
-   `inv/one/group_vars/foo.yaml` : Is winning over previous, because it’s not ‘all’ group, it has higher precedence.
-   `inv/two/group_vars/foo.yaml` : Is winning over previous, because it’s later in the command line.
-   `group_vars/foo.yaml` : Is the final winner, because it’s not ‘all’, and it’s playbook group vars. There is no stronger group vars than this.

Who is winning over `group_vars/foo.yaml`? Well, actually, it’s just #7 out of 22, so, there are tons of stronger things out there. Hostvars, play vars, etc, etc.

## Even more complexities

I hand’t touched yet another nuance, it’s called parent/children relationship between groups. If one group is in parent/children relationship, they have additional rules to look for. You can find them by `ansible_group_priority` . I won’t go that deep here, but you need to understand, that example above is _simplification._

## Considerations

Whilst overriding variables can be useful for DRY, it should be used sparsely.

Every time you use overriding (outside of role defaults, which loses almost to everything) and role parameters (which wins over almost everything), you need to be really careful.

This article was written during thoughts about refactoring. I wanted to move group variables from hosts.yml to `group_vars`. It would be a real issue if not considered properly, because it would have had caused incorrect priorities with secondary inventories.

I’m not sure if I helped anyone to understand this topic better, but at least I gave a path to glimpse into (and to consider if you want to go this road at all…).

## Reference

- https://medium.com/opsops/the-subtlety-of-group-vars-directory-8687d1405bad
