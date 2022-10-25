
# Test Driven Development

So you're doing Infrastructure-as-Code? Sure. But have you ever heard of test-driven development (TDD)? It's that dev team thing, right? Hell no! It should be equally important to infrastructure coding.

## What about TDD in Infrastructure-as-Code?

[Infrastructure-as-Code (IaC)](https://en.wikipedia.org/wiki/Infrastructure_as_code) has really become one of those buzzwords lately. And the reason is: **it's just really cool to describe your whole infrastructure with code.** Versioned by Git. Abstracted from the gory details by Ansible & Co. And last but most importantly: extracted from those head monopolies! There are so many reasons to do IaC. But if you're a software engineer by heart like me, there's maybe a gut instinct telling you: there's something missing in this game. **What about the principles of modern software engineering?**

![test-driven infrastructure meme](./img/9R8s3a8OSOqrUdEBO36Q.jpeg)

We all learned hard lessons until most of us agreed on the undeniable benefits of [Test-driven development (TDD)](https://en.wikipedia.org/wiki/Test-driven_development) and Continuous Integration & Delivery (CI/CD). But didn't we somehow forget about them? Moving over to those new shiny DevOps tools, we keep saying: “Let's do infrastructure as code!” leaving methodologies like TDD & CI/CD to the “software development” teams. We're now ops right?! **No way!** That should be the whole point of Infrastructure-as-Code. We're software developers although the job posting says “DevOps”. We just develop infrastructure. 🙂

If you’ve already developed some infrastructure and left this code untouched for a month or two… and then got your hands on it again trying to execute it and just see it failing on things you never saw before – just a thousand libraries, APIs and version upgrades since the last code execution – and everything just stopped working (note:**code that is not automatically and constantly executed and tested will eventually rot sooner or later!**), this should be enough reason to bring Test-driven development and Continuous Integration into the world of infrastructure coding.

To summarize, the Test-driven-development (TDD) process is to 

1) divide the problem into parts, 
2) write a functional test for each part, 
3) write code for each part, 
4) see if functional tests passes/fails and 
5) refactor code accordingly until success.

Here is a workflow suggested in the book [Test-Driven Development with Python](http://chimera.labs.oreilly.com/books/1234000000754) by Harry Percival (available online for free).

![TDD Workflow Overview](./img/tdd_flowchart_functional_and_unit_with_red_and_green.png)

## TDD for infrastructure code development using Ansible, Molecule & TestInfra

Part 1: [Test-driven infrastructure development with Ansible & Molecule](./test-driven-infrastructure-ansible-molecule-and-testinfra.md)  
Part 2: [Continuous Infrastructure with Ansible, Molecule & TravisCI](tdd-continuous-infrastructure-ansible-molecule-travisci.md)  
Part 3: [Continuous cloud infrastructure with Ansible, Molecule & TravisCI on AWS](tdd-ansible-molecule-travisci-aws.md)

## Importance of Functional Test Environment

The functional test workflow uses a "production-like" functional test environment to run validation tests for all specified functions / features.

The key motivation is to front-center the need to have an actual dedicated fixed QA/Functional test environment with separate credentials - not touching production assets (to the extent possible) - setup to fully enable this workflow - which is essential to infrastructure code development.

### Mitigates risk of "code in development"

NO developer writes "perfect" code "All the time" and as such, you would never let developers develop code against your production environment.  This is even more critical/true for infrastructure automation development since if code is not written to work correctly it can (and will) screw up your production environment.

### Mitigates risk of "lack of initial feature clarity/understanding"

Another factor to consider is that the feature under development is not necessarily entirely clear or well-understood at the time of the initial request.  Often times, especially for more complex/highly integrated features, the feature set gets elaborated as the development iterates towards a clearer solution/implementation.

## Code development is highly iterative in nature

By adopting "test-driven-development" you readily admit code development requires many iterations of "developing functional test cases", "develop functional code", "Test the function", "refactor the code until FT success", repeat cycle for each requested feature set throughout time and include already developed feature tests in next iteration. 

This is the realistic code development paradigm and using a TDD process/approach achieves high level of QA by adopting repeatable and automatable validation test validation criteria and processes used.

## Reference

- [Molecule](https://molecule.readthedocs.io/en/2.20/configuration.html)
- [Molecule on github.com](https://github.com/ansible/molecule)
- [Ansible](https://www.ansible.com/)
- [Inspec](https://www.inspec.io/)
- [Goss](https://goss.rocks/)
- [Testinfra](https://testinfra.readthedocs.io/en/latest/)
- [test-driven-infrastructure with ansible molecule and testinfra](https://blog.codecentric.de/test-driven-infrastructure-ansible-molecule)
- [TDD with ansible](https://d-heinrich.medium.com/test-driven-development-with-ansible-using-molecule-3386cef987ac)
- https://d-heinrich.medium.com/test-driven-development-with-ansible-using-molecule-3386cef987ac
- https://testdriven.io/blog/modern-tdd/
- https://code.tutsplus.com/tutorials/beginning-test-driven-development-in-python--net-30137
- https://www.freecodecamp.org/news/learning-to-test-with-python-997ace2d8abe/
- https://www.ideamotive.co/blog/test-driven-development-with-python
- https://www.guru99.com/test-driven-development.html
- https://stackoverflow.com/questions/4658382/test-driven-development-tdd-for-user-interface-ui-with-functional-tests
- https://www.oreilly.com/library/view/test-driven-development-with/9781491958698/app08.html
- https://xenonstack.wordpress.com/2018/03/13/test-driven-development-behavior-driven-development-in-golang/
- https://www.tmap.net/wiki/test-driven-development
- Agarwal, R., & Umphress, D. (2008). Extreme programming for a single person team. Proceedings of the 46th Annual Southeast Regional Conference (ACM-SE 46), 82–87. New York, NY, USA: ACM. DOI: 10.1145/1593105.1593127 
- Bhat, T., & Nagappan, N. (2006). Evaluating the efficacy of test-driven development: industrial case studies. 2006 ACM/IEEE international symposium on Empirical software engineering (ISESE), 356–363. New York, NY, USA: ACM. DOI: 10.1145/1159733.1159787 
- Gupta, A., & Jalote, P. (2007). An Experimental Evaluation of the Effectiveness and Efficiency of the Test Driven Development. First International Symposium on Empirical Software Engineering and Measurement (ESEM), 285–294. DOI: 110.1109/ESEM.2007.41 
- Olan, M. (2003). Unit testing: test early, test often. Journal of Computing Sciences in Colleges, 19(2), 319–328. Retrieved from ACM Digital Library 
- Vu, J. H., Frojd, N., Shenkel-Therolf, C., & Janzen, D. S. (2009). Evaluating Test-Driven Development in an Industry-Sponsored Capstone Project. Sixth International Conference on Information Technology: New Generations (ITNG), 229–234. DOI: 10.1109/ITNG.2009.11 
- Williams, L., Maximilien, E. M., & Vouk, M. (2003). Test-driven development as a defect-reduction practice. 14th International Symposium on Software Reliability Engineering (ISSRE), 34–45. DOI: 10.1109/ISSRE.2003.1251029
