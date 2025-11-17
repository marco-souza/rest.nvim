# Spec-Driven Development (SDD) Guide

This directory contains specifications for all features and improvements to term.nvim using Spec-Driven Development methodology.

## What is SDD?

Spec-Driven Development is a collaborative approach where:
1. **Specify** - Define the problem, user journeys, and requirements clearly
2. **Plan** - Break down the specification into technical decisions
3. **Implement** - Execute tasks guided by the specification
4. **Validate** - Ensure implementation matches the specification

The specification becomes the **source of truth** for implementation, not code written first with docs added later.

## Structure

- `001-template-specification.md` - Template for all new specifications
- `NNN-feature-name.md` - Actual feature specifications (where NNN is sequential number)

## Workflow

### Step 1: Create Specification
1. Copy `001-template-specification.md` to `NNN-feature-name.md`
2. Fill in all sections (even if some are "TBD")
3. Focus on **what** you're building, not **how**
4. Include user journeys and acceptance criteria

**Exit Criteria:** Specification is clear enough that someone else could understand what to build

### Step 2: Request Review
1. Submit PR with specification
2. Mark status as "In Review"
3. Address reviewer feedback
4. Update specification based on discussion
5. Get approval from at least one reviewer

**Exit Criteria:** All stakeholders agree on what needs to be built

### Step 3: Create Technical Plan
Once spec is approved:
1. Create `NNN-feature-name-plan.md`
2. Document:
   - Architecture changes
   - Module modifications
   - New dependencies
   - Database/API changes
   - Testing approach

**Exit Criteria:** Tech plan is detailed enough for implementation

### Step 4: Break Into Tasks
1. Create `NNN-feature-name-tasks.md`
2. Break plan into small, reviewable chunks
3. Each task should be:
   - Implementable in 1-2 days of work
   - Independently testable
   - Clear definition of done

**Exit Criteria:** Tasks are ready for implementation

### Step 5: Implement
Implement tasks one by one, guided by the spec and plan.

### Step 6: Validate
1. Verify all acceptance criteria met
2. Run tests
3. Update spec status to "Complete"
4. Archive completed spec

## Key Principles

✅ **Collaboration First** - Specs are conversation starters, not final documents  
✅ **Clarity** - Clear requirements reduce implementation time  
✅ **Iterative** - Specs can be refined as understanding grows  
✅ **Executable** - Break specs into concrete, testable tasks  
✅ **Non-Negotiable Values** - Keep `CONSTITUTION.md` in mind

## Spec Quality Checklist

Before submitting for review, ensure your spec:

- [ ] Has clear problem statement
- [ ] Includes at least 2 user journeys
- [ ] Has specific, measurable success criteria
- [ ] Lists all functional requirements (FR-1, FR-2, etc.)
- [ ] Addresses non-functional requirements
- [ ] Identifies edge cases
- [ ] Notes technical risks
- [ ] Lists open questions with assignees
- [ ] Is 2-5 pages long (not exhaustive)
- [ ] Can be understood by non-technical stakeholders

## Examples

### Good Spec Characteristics
- Focuses on **why** and **what**, not **how**
- Uses real-world examples (user journeys)
- Clear acceptance criteria (testable)
- Identifies constraints early
- Documents assumptions
- Suggests but doesn't mandate implementation details

### Weak Spec Characteristics
- ❌ "Use Rust for performance" (how, not what)
- ❌ "Fast API endpoint" (vague, unmeasurable)
- ❌ "Similar to Jira" (assumes knowledge, not explicit)
- ❌ "TBD for everything" (no real thinking done)
- ❌ 20+ pages of detail (overthinking)

## Status Definitions

- **Draft** - Spec is being written, not ready for review
- **In Review** - Submitted for feedback, awaiting approval
- **Approved** - Stakeholders agree, ready for planning
- **Implementing** - Technical plan created, tasks in progress
- **Complete** - All acceptance criteria met, merged
- **On Hold** - Paused, waiting for dependencies or feedback

## Template Reference

Use `001-template-specification.md` as your starting point. Don't skip sections even if content is minimal:
- Section empty? Write "TBD - will clarify with team"
- Section not applicable? Write "N/A - not relevant for this feature"

## Tools & Integration

- **Language:** Markdown (version control friendly, human readable)
- **Review:** GitHub PR comments on spec files
- **Tracking:** Use spec status field + GitHub issues
- **Automation:** Spec → Technical Plan → Tasks → Implementation

## Resources

- [GitHub Spec Kit](https://github.com/github/spec-kit)
- [Spec-Driven Development Blog Post](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [BDD & Gherkin](https://cucumber.io/docs/bdd/)

## Questions?

If you have questions about the SDD process:
1. Check this README
2. Review existing specs in this directory
3. Ask in team discussions
4. Update this README if you found a gap
