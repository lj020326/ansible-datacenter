
* https://github.com/ansible/ansible/issues/30882#issuecomment-380596557

> bcoca commented on Apr 11, 2018 •
>
> So include had many 'magical' behaviors and we are trying to make them explicit and clear, at one point we added the ability to ignore 'specified' tags so we could run tasks depending on include tasks.
>  The behaviour you see is intentional, the new import_ and include_ were created to remove much of this magic and establish clear behaviors depending on which one is used.
>
> import_ <- no keywords apply to it, it always happens and any keywords are inherited by contained tasks. 
> So this will have the behaviour of ignoring tags on itself and NOT condition execution based on them.
>
> include_ <- keywords apply to it and are NOT inherited by contained tasks. So this will NOT ignore tags and WILL condition it's execution based on them.
> 
> You can get mostly what include did with include_ by adding tags: ['always'] to ensure the include_ executes by default no matter what tags you specify. There are other workarounds using block or just going back to include which we want to eventually remove but not until all cases are covered by the new actions.
> 
> Another feature we plan, to help with include_ inheritance: #38262 (comment), which does not really affect this issue but does affect how you tag in general.
> 
> There are more differences between include_and import_ and you can read those at http://docs.ansible.com/ansible/latest/porting_guides/porting_guide_2.5.html#dynamic-includes-and-attribute-inheritance
> 
> Hope that explains and helps all.



[dynamic-includes](https://github.com/ansible/ansible/issues/30882#issuecomment-355857592)

> When it comes to Ansible task options like tags and conditional statements (when:):<br>
> * For dynamic includes, the task options will only apply to the dynamic task as it is evaluated, and will not be copied to child tasks.<br>
> * For static imports, the parent task options will be copied to all child tasks contained within the import.

* https://github.com/ansible/ansible/issues/30882
* https://github.com/ansible/ansible/issues/34974

Comments:

  That reads like imports would be required to apply the tags down through the tasks

  So by doing import, every task within the imported tasks gets the "section02" tag copied to it

  Since that's always, it's copying always down to every task

  with include, the tag only applies to the include itself

  That makes sense then. I misread that as "if you want the tags you defined to be available to the tasks below, use import"

  so its completely useless tagging individual tasks in plays that will be imported
  Inconsistent behavior for include and import

  And note that "when" would also be copied to all the tasks with an import as well

  interesting - so - maybe even more reason to avoid import

