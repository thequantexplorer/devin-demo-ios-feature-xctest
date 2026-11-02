# Spec: search and sort the expense list

## Problem

The list shows every expense, newest first, and nothing else. People with more than a few
expenses can't find one quickly, and they can't see their biggest costs at the top.

## What to build

A search field and a sort menu on the main list.

## Acceptance criteria

### Search

1. The list has a search field with the placeholder **Search expenses** (use `.searchable`).
2. Search matches the expense **title** or its **category** name. "food" finds both
   "Groceries" and "Coffee beans".
3. Matching ignores case and leading or trailing spaces. "  COFFEE " finds "Coffee beans".
4. An empty search shows every expense.
5. When nothing matches, the list shows the standard empty search state
   (`ContentUnavailableView.search`), not a blank screen.
6. The **Total** row shows the sum of the expenses that are currently shown.
   Searching "transport" shows a total of **$133.75**.

### Sort

7. The toolbar has a **Sort** menu (accessibility identifier `sortMenu`) with these options,
   in this order:
   - **Newest first** (the default)
   - **Oldest first**
   - **Amount: high to low**
   - **Amount: low to high**
   - **Title: A to Z**
8. The menu shows a checkmark next to the current option.
9. Ties are always broken by title, A to Z. For example, "Coffee beans" and "Pharmacy" both cost
   $18.50, so with **Amount: low to high** "Coffee beans" comes first.
10. Search and sort work together: the sort applies to the search results.
11. Adding or deleting an expense keeps the current search and sort.

## Out of scope

- Saving the search or sort choice between launches.
- Filtering by date range or by amount.

## Notes for the implementation

- Keep filtering and sorting out of the view, in a type that unit tests can call directly.
- The sample data in `Expenses/Models/SampleData.swift` is fixed, so tests can assert exact
  results. The full total is $621.64.
