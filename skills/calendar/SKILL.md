---
name: calendar
description: Add an event described on a website to Google Calendar. Use when the user gives an event page URL and asks to put it in their calendar.
argument-hint: <url> [calendar name]
allowed-tools:
  - WebFetch
  - mcp__claude_ai_Google_Calendar__list_calendars
  - mcp__claude_ai_Google_Calendar__list_events
  - mcp__claude_ai_Google_Calendar__create_event
---

# Add a website event to Google Calendar

Arguments: `$ARGUMENTS`: the URL of a page describing an event, optionally followed by the name of the calendar to add it to.

1. Fetch the page with `WebFetch` and extract the event title, every date with its start and end time, the timezone, and the venue name and address.
2. Resolve the calendar with `list_calendars`, matching the given name against the calendar summaries. Use the **Tentative** calendar if no calendar was named.
3. Check for conflicts: use `list_events` on the **Private** and **Work** calendars for the time span of each date. If the event overlaps with anything there, name the conflicting events and ask for explicit permission before creating it. A single-day all-day entry counts as an overlap only if the new event is all-day too; an all-day entry spanning several days always counts.
4. Create the event with `create_event`:
   - `summary`: the event title as shown on the page.
   - `startTime` / `endTime`: as listed on the page. Use `timeZone: Europe/Amsterdam` unless the page states another timezone.
   - `description`: a link to the page (`<a href="URL">URL</a>`).
   - `location`: venue name and full address, if the page gives them. For an online event, leave it out.

- If the page lists several dates or sessions, create one event per date. Create the dates without conflicts right away and ask only about the conflicting ones.
- If no end time is given, assume the event lasts two hours and say so. If no time is given at all, create an all-day event.
- If the page can't be fetched or shows no date, say so instead of guessing.
- If no URL was given, use the event page most recently discussed in the conversation; ask if that's unclear.
- Don't add attendees, reminders or a Meet link unless asked.

Reply with one short line per event created: title, date and time, calendar, and the link to the event in Google Calendar.
