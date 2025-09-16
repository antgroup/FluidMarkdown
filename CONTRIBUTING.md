## Contributing to FluidMarkdown

Thank you for your interest in contributing to FluidMarkdown!

## Clone the code repository

```plain
git clone git@github.com:antgroup/FluidMarkdown.git

cd FluidMarkdown
```

## Make a change

1. Create a new branch for your feature or fix

```plain
git checkout -b feature/your-feature-name
```

2. Make changes and ensure
    1. All tests pass
    2. Code is properly formatted
    3. Necessary comments are included<
3. Write test cases for your changes

## Submission guidelines

Please follow the commit log specification to get a clear historical commit record

+ feat: New features
+ fix: Bug fixes
+ docs: Documentation changes
+ style: Code style changes (formatting, etc.)
+ refactor: Code changes neither fix bugs nor add functionality
+ test: Add or update a test
+ chore: Maintenance tasks
For example:

```plain
feat: add support for custom code block themes
fix: resolve markdown parsing issue with nested lists
docs: update README with new API examples
```

## Pull request review process

1. Make sure your PR:
    1. Has a clear, descriptive title
    2. Contains a changeset (run `pnpm changeset` if one hasn’t been added)
    3. Passes all CI checks. Including new feature testing
    4. Updates documentation if necessary
2. The PR description should include:
    1. What changes have been made
    2. Why these changes are necessary
    3. Any major changes Screenshots/Demos of UI changes
3. Uses keywords to link any related questions, e.g.Fixes #123 or Closes #456
   
## Coding style

+ Follows the existing coding style in the project
+ Uses meaningful variable and function names
+ Adds comments to complex logic
+ Keeps features small and focused

## License

By contributing to FluidMarkdown, you agree that your contributions will be licensed under the Apache-2.0.

  



