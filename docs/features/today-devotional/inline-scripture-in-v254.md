# Inline scripture in the readings' own text

The 366 readings bundled with the app are v254's (`versions/app-v254.html` at `3ff4a6f`; the maintainer's decision of 2026-11-12, recorded in the [feature contract](feature.md)). They quote scripture not only in the verse of the day but also inside the headline, the prayer, the "In Jesus" paragraph and the action. This page lists every place that was found. It is the evidence for the row "Check the readings' inline scripture" on the [work board](../../knowledge/WORK.md).

**How it was made.** By a read-only script on 2026-11-12, not by reading. A run of words counts as scripture only where it matches scripture text already in the repository: the BSB verses in `seed/devotionals.json`, the ESV verses in `seed/esv-verses.json`, and v254's own verse text, which v254 labels ESV. Nothing was judged from memory. So scripture quoted from a verse that is **not** in the repository can be found only where it stands in quotation marks or beside a reference (sections B and C), and its translation cannot be told from the repository at all.

**What this page does not settle.** Whether each quotation is word for word what a published Bible says; which translation an unmatched quotation is; and whether ESV wording in these places counts toward the ESV limit. That is the work of the board row. Owner: the maintainer. Do it before public release.

## Summary

| What was found | Count |
|---|---|
| **Clear inline quotations:** 8 or more words in a row of a verse that is in the repository | 23, on 23 dates: 10 in ESV wording, 9 the same in the BSB and the ESV, 4 in BSB wording |
| Shorter overlaps of 5 to 7 words, which may be quotation or coincidence | 90 |
| **Quoted spans that match no scripture in the repository** | 35, on 32 dates: 20 in Act (most are words for him to say), 12 in "In Jesus", 3 in Prayer |
| Of those, quoted with a reference named beside them | 7 spans naming 6 references. **5 of those verses are not in the ESV file** |
| References named in running text | 82 mentions, 71 distinct. 43 of them, covering 63 verses, are not among the bundled ESV verses |

**The ESV limit and the ESV notice.** The limit test counts the 437 distinct verses in `seed/esv-verses.json` and nothing else, so inline ESV wording is not counted. The ESV notice is shown under the verse of the day when its ESV tab is open; inline ESV wording in a headline, prayer or "In Jesus" paragraph is shown with no notice beside it.

## The 23 clear quotations

| Date | Part | Wording | Verse quoted | Words in a row | The words matched |
|---|---|---|---|---|---|
| 01-17 | Prayer | Same in the BSB and the ESV | the day's own verse | 9 | as far as the east is from the west |
| 01-19 | In Jesus | ESV wording | Matthew 11:28–30 | 16 | come to me all who labor and are heavy laden and i will give you rest |
| 01-29 | In Jesus | ESV wording | the day's own verse | 12 | christ was raised from the dead by the glory of the father |
| 02-05 | In Jesus | BSB wording | the day's own verse | 10 | the son of man did not come to be served |
| 03-06 | In Jesus | Same in the BSB and the ESV | 1 Peter 2:24 | 9 | bore our sins in his body on the tree |
| 03-13 | In Jesus | ESV wording | Matthew 11:28–30 | 16 | come to me all who labor and are heavy laden and i will give you rest |
| 05-17 | In Jesus | Same in the BSB and the ESV | Romans 8:32 | 13 | did not spare his own son but gave him up for us all |
| 05-29 | Prayer | BSB wording | the day's own verse | 10 | jesus grew in wisdom and stature and in favor with |
| 06-07 | In Jesus | ESV wording | Matthew 11:28–30 | 16 | come to me all who labor and are heavy laden and i will give you rest |
| 06-08 | In Jesus | ESV wording | Mark 10:45 | 18 | came not to be served but to serve and to give his life as a ransom for many |
| 06-17 | In Jesus | Same in the BSB and the ESV | Romans 8:32 | 13 | did not spare his own son but gave him up for us all |
| 06-21 | In Jesus | ESV wording | Mark 6:31 | 12 | come away by yourselves to a desolate place and rest a while |
| 07-29 | In Jesus | Same in the BSB and the ESV | Romans 8:32 | 13 | did not spare his own son but gave him up for us all |
| 08-03 | In Jesus | Same in the BSB and the ESV | 1 Peter 2:24 | 9 | bore our sins in his body on the tree |
| 08-20 | In Jesus | BSB wording | Mark 10:45 | 19 | did not come to be served but to serve and to give his life as a ransom for many |
| 08-25 | Prayer | ESV wording | the day's own verse | 9 | who call on the lord from a pure heart |
| 09-27 | Prayer | ESV wording | the day's own verse | 9 | in me and lead me in the way everlasting |
| 09-30 | In Jesus | Same in the BSB and the ESV | the day's own verse | 8 | is able to keep you from stumbling and |
| 10-28 | Prayer | ESV wording | the day's own verse | 8 | isaac went out to meditate in the field |
| 11-07 | In Jesus | Same in the BSB and the ESV | 1 Peter 2:24 | 9 | bore our sins in his body on the tree |
| 11-15 | Prayer | ESV wording | the day's own verse | 9 | the lines have fallen for me in pleasant places |
| 12-01 | Prayer | Same in the BSB and the ESV | the day's own verse | 9 | wonderful counselor mighty god everlasting father prince of peace |
| 12-20 | In Jesus | BSB wording | the day's own verse | 8 | born under the law to redeem those under |

## Quoted with a reference named beside the quotation

The words in quotation marks match no verse in the repository, so the repository cannot say which translation they are.

| Date | Part | Quoted | Reference named | Is that verse in the ESV file? |
|---|---|---|---|---|
| 06-04 | In Jesus | “He has done all things well” | Mark 7:37 | No |
| 06-05 | In Jesus | “My Father is working until now, and I am working” | John 5:17 | No |
| 06-05 | In Jesus | “It is finished.” | John 5:17 | No |
| 06-06 | In Jesus | “I have come down from heaven, not to do my own will but the will of him who sent me” | John 6:38 | No |
| 06-09 | In Jesus | “I am the bread of life; whoever comes to me shall not hunger” | John 6:35 | No |
| 06-20 | In Jesus | “I am the good shepherd. I know my own and my own know me” | John 10:14 | No |
| 08-17 | In Jesus | “Your sins are forgiven” | Mark 2:5 | Yes |

The five verses not in the ESV file: John 5:17, John 6:35, John 6:38, John 10:14, Mark 7:37.

## A. Every run of 5 or more words that matches a verse in the repository

113 places on 102 dates, the 23 above included. The longest run in each part of each reading is listed. Words are shown in lower case without punctuation, as the script compared them.

| Date | Part | Wording | Verse matched | Words in a row | The words matched |
|---|---|---|---|---|---|
| 01-12 | In Jesus | ESV wording | the day's own verse | 5 | your life is hidden with |
| 01-12 | Prayer | ESV wording | the day's own verse | 6 | life is hidden with christ in |
| 01-16 | Headline | Same in the BSB and the ESV | the day's own verse | 5 | out of darkness into his |
| 01-17 | Prayer | Same in the BSB and the ESV | the day's own verse | 9 | as far as the east is from the west |
| 01-19 | In Jesus | ESV wording | Matthew 11:28–30 | 16 | come to me all who labor and are heavy laden and i will give you rest |
| 01-20 | In Jesus | Same in the BSB and the ESV | the day's own verse | 7 | the right to become children of god |
| 01-21 | In Jesus | BSB wording | the day's own verse | 5 | the day of christ jesus |
| 01-27 | In Jesus | ESV wording | the day's own verse | 6 | you received christ jesus the lord |
| 01-29 | In Jesus | ESV wording | the day's own verse | 12 | christ was raised from the dead by the glory of the father |
| 01-30 | In Jesus | ESV wording | Hebrews 12:2 | 7 | the founder and perfecter of our faith |
| 02-02 | In Jesus | ESV wording | the day's own verse | 5 | in deed and in truth |
| 02-05 | In Jesus | BSB wording | the day's own verse | 10 | the son of man did not come to be served |
| 02-05 | Prayer | Same in the BSB and the ESV | the day's own verse | 5 | life as a ransom for |
| 02-15 | In Jesus | BSB wording | the day's own verse | 6 | is the first and greatest commandment |
| 02-18 | Prayer | Same in the BSB and the ESV | the day's own verse | 5 | a covenant with my eyes |
| 02-21 | In Jesus | Same in the BSB and the ESV | Hebrews 12:2 | 6 | at the right hand of the |
| 02-24 | In Jesus | Same in the BSB and the ESV | John 1:14 | 5 | full of grace and truth |
| 02-26 | In Jesus | ESV wording | the day's own verse | 6 | not insist on its own way |
| 02-28 | Prayer | Same in the BSB and the ESV | the day's own verse | 5 | rejoice in the wife of |
| 03-03 | In Jesus | ESV wording | Matthew 4:4 | 5 | not live by bread alone |
| 03-04 | In Jesus | ESV wording | Hebrews 12:2 | 7 | the founder and perfecter of our faith |
| 03-06 | In Jesus | Same in the BSB and the ESV | 1 Peter 2:24 | 9 | bore our sins in his body on the tree |
| 03-10 | Prayer | ESV wording | the day's own verse | 6 | a man without self control is |
| 03-13 | In Jesus | ESV wording | Matthew 11:28–30 | 16 | come to me all who labor and are heavy laden and i will give you rest |
| 03-13 | Prayer | Same in the BSB and the ESV | the day's own verse | 5 | power to the faint and |
| 03-15 | In Jesus | BSB wording | Hebrews 4:15 | 5 | was tempted in every way |
| 03-19 | In Jesus | ESV wording | John 16:33 | 5 | these things to you that |
| 03-20 | In Jesus | ESV wording | John 14:27 | 5 | not as the world gives |
| 03-30 | In Jesus | BSB wording | 1 Corinthians 10:13 | 5 | god is faithful he will |
| 03-30 | Prayer | Same in the BSB and the ESV | the day's own verse | 7 | the coming of our lord jesus christ |
| 03-31 | Headline | Same in the BSB and the ESV | the day's own verse | 6 | is the strength of my heart |
| 04-01 | In Jesus | ESV wording | 1 Peter 2:24 | 5 | by his wounds you have |
| 04-03 | In Jesus | BSB wording | the day's own verse | 5 | everyone who believes in him |
| 04-06 | Prayer | Same in the BSB and the ESV | the day's own verse | 5 | not my will but yours |
| 04-11 | In Jesus | ESV wording | the day's own verse | 6 | said it is finished and he |
| 04-14 | In Jesus | ESV wording | the day's own verse | 5 | the founder and perfecter of |
| 04-14 | Prayer | BSB wording | the day's own verse | 6 | for the joy set before him |
| 04-16 | In Jesus | Same in the BSB and the ESV | the day's own verse | 5 | the sting of death is |
| 04-16 | Prayer | Same in the BSB and the ESV | the day's own verse | 5 | through our lord jesus christ |
| 04-21 | In Jesus | ESV wording | the day's own verse | 6 | power is made perfect in weakness |
| 04-23 | In Jesus | Same in the BSB and the ESV | the day's own verse | 5 | through our lord jesus christ |
| 04-24 | In Jesus | Same in the BSB and the ESV | the day's own verse | 5 | the iniquity of us all |
| 04-28 | In Jesus | Same in the BSB and the ESV | the day's own verse | 6 | raised christ jesus from the dead |
| 04-28 | Prayer | Same in the BSB and the ESV | the day's own verse | 5 | raised jesus from the dead |
| 05-17 | In Jesus | Same in the BSB and the ESV | Romans 8:32 | 13 | did not spare his own son but gave him up for us all |
| 05-17 | Prayer | Same in the BSB and the ESV | the day's own verse | 6 | give good gifts to your children |
| 05-28 | In Jesus | ESV wording | Ephesians 6:10 | 5 | in the strength of his |
| 05-29 | Prayer | BSB wording | the day's own verse | 10 | jesus grew in wisdom and stature and in favor with |
| 06-01 | In Jesus | BSB wording | the day's own verse | 7 | is the lord christ you are serving |
| 06-05 | In Jesus | Same in the BSB and the ESV | John 19:30 | 5 | he said it is finished |
| 06-07 | In Jesus | ESV wording | Matthew 11:28–30 | 16 | come to me all who labor and are heavy laden and i will give you rest |
| 06-08 | In Jesus | ESV wording | Mark 10:45 | 18 | came not to be served but to serve and to give his life as a ransom for many |
| 06-15 | In Jesus | Same in the BSB and the ESV | Philippians 2:6–7 | 5 | the form of a servant |
| 06-15 | Prayer | Same in the BSB and the ESV | Philippians 2:6–7 | 5 | the form of a servant |
| 06-17 | In Jesus | Same in the BSB and the ESV | Romans 8:32 | 13 | did not spare his own son but gave him up for us all |
| 06-20 | Headline | BSB wording | the day's own verse | 5 | know the state of your |
| 06-21 | In Jesus | ESV wording | Mark 6:31 | 12 | come away by yourselves to a desolate place and rest a while |
| 06-25 | Prayer | ESV wording | the day's own verse | 5 | say if the lord wills |
| 07-03 | Prayer | BSB wording | the day's own verse | 5 | power love and self control |
| 07-08 | Prayer | Same in the BSB and the ESV | the day's own verse | 6 | for such a time as this |
| 07-09 | In Jesus | Same in the BSB and the ESV | Luke 22:42 | 5 | not my will but yours |
| 07-11 | Headline | ESV wording | the day's own verse | 5 | they had been with jesus |
| 07-17 | In Jesus | Same in the BSB and the ESV | John 19:30 | 5 | he said it is finished |
| 07-18 | In Jesus | Same in the BSB and the ESV | the day's own verse | 5 | the lord is with you |
| 07-22 | In Jesus | ESV wording | 2 Corinthians 12:9 | 6 | power is made perfect in weakness |
| 07-24 | Prayer | ESV wording | the day's own verse | 5 | be honored in my body |
| 07-29 | In Jesus | Same in the BSB and the ESV | Romans 8:32 | 13 | did not spare his own son but gave him up for us all |
| 08-02 | Prayer | ESV wording | the day's own verse | 5 | friend who sticks closer than |
| 08-03 | In Jesus | Same in the BSB and the ESV | 1 Peter 2:24 | 9 | bore our sins in his body on the tree |
| 08-08 | In Jesus | ESV wording | Isaiah 53:5 | 5 | his wounds we are healed |
| 08-09 | In Jesus | Same in the BSB and the ESV | Romans 5:8 | 5 | while we were still sinners |
| 08-20 | In Jesus | BSB wording | Mark 10:45 | 19 | did not come to be served but to serve and to give his life as a ransom for many |
| 08-25 | In Jesus | BSB wording | Hebrews 4:15 | 5 | was tempted in every way |
| 08-25 | Prayer | ESV wording | the day's own verse | 9 | who call on the lord from a pure heart |
| 08-29 | Prayer | Same in the BSB and the ESV | the day's own verse | 5 | let the word of christ |
| 09-04 | Prayer | Same in the BSB and the ESV | the day's own verse | 5 | a covenant with my eyes |
| 09-11 | In Jesus | ESV wording | Hebrews 4:16 | 5 | to the throne of grace |
| 09-14 | In Jesus | ESV wording | the day's own verse | 6 | put on the lord jesus christ |
| 09-23 | Prayer | Same in the BSB and the ESV | the day's own verse | 5 | body in holiness and honor |
| 09-24 | Prayer | BSB wording | the day's own verse | 6 | me examine my heart and mind |
| 09-27 | Prayer | ESV wording | the day's own verse | 9 | in me and lead me in the way everlasting |
| 09-30 | In Jesus | Same in the BSB and the ESV | the day's own verse | 8 | is able to keep you from stumbling and |
| 10-02 | Act | ESV wording | the day's own verse | 5 | shut the door and pray |
| 10-05 | In Jesus | ESV wording | Hebrews 4:15 | 6 | as we are yet without sin |
| 10-10 | In Jesus | ESV wording | the day's own verse | 6 | to pray and not lose heart |
| 10-12 | In Jesus | Same in the BSB and the ESV | Hebrews 12:2 | 5 | at the right hand of |
| 10-23 | Prayer | BSB wording | the day's own verse | 6 | elijah was a man just like |
| 10-28 | Prayer | ESV wording | the day's own verse | 8 | isaac went out to meditate in the field |
| 10-29 | Prayer | BSB wording | the day's own verse | 6 | with every kind of prayer and |
| 11-05 | Headline | BSB wording | Deuteronomy 31:6 | 5 | he will never leave you |
| 11-07 | In Jesus | Same in the BSB and the ESV | 1 Peter 2:24 | 9 | bore our sins in his body on the tree |
| 11-10 | In Jesus | Same in the BSB and the ESV | Mark 10:45 | 7 | his life as a ransom for many |
| 11-13 | In Jesus | ESV wording | Philippians 2:6–7 | 6 | did not count equality with god |
| 11-15 | Prayer | ESV wording | the day's own verse | 9 | the lines have fallen for me in pleasant places |
| 11-16 | In Jesus | Same in the BSB and the ESV | the day's own verse | 5 | the god of my salvation |
| 11-20 | In Jesus | Same in the BSB and the ESV | Romans 5:8 | 5 | while we were still sinners |
| 11-23 | In Jesus | BSB wording | Hebrews 12:2 | 6 | for the joy set before him |
| 11-26 | In Jesus | Same in the BSB and the ESV | Matthew 6:11–12 | 7 | give us this day our daily bread |
| 11-26 | Prayer | Same in the BSB and the ESV | the day's own verse | 6 | give me neither poverty nor riches |
| 12-01 | Prayer | Same in the BSB and the ESV | the day's own verse | 9 | wonderful counselor mighty god everlasting father prince of peace |
| 12-02 | In Jesus | ESV wording | the day's own verse | 6 | shoot from the stump of jesse |
| 12-06 | In Jesus | Same in the BSB and the ESV | the day's own verse | 6 | save his people from their sins |
| 12-09 | Prayer | BSB wording | the day's own verse | 5 | because there was no room |
| 12-10 | In Jesus | Same in the BSB and the ESV | the day's own verse | 5 | in the city of david |
| 12-15 | In Jesus | BSB wording | the day's own verse | 5 | full of grace and truth |
| 12-16 | In Jesus | Same in the BSB and the ESV | the day's own verse | 5 | the form of a servant |
| 12-17 | In Jesus | Same in the BSB and the ESV | Mark 10:45 | 6 | life as a ransom for many |
| 12-20 | In Jesus | BSB wording | the day's own verse | 8 | born under the law to redeem those under |
| 12-23 | In Jesus | ESV wording | the day's own verse | 6 | gentle and lowly in heart and |
| 12-26 | In Jesus | Same in the BSB and the ESV | the day's own verse | 5 | our great god and savior |
| 12-27 | Prayer | Same in the BSB and the ESV | the day's own verse | 7 | king of kings and lord of lords |
| 12-28 | In Jesus | Same in the BSB and the ESV | Luke 22:42 | 7 | not my will but yours be done |
| 12-31 | In Jesus | Same in the BSB and the ESV | John 19:30 | 5 | he said it is finished |

## B. Every quoted span that matches no scripture in the repository

35 spans on 32 dates: text in quotation marks, 12 characters or longer. Some are words for him to say; some are scripture.

| Date | Part | Quoted | Reference named in the same part |
|---|---|---|---|
| 01-15 | Act | “Jesus paid for this,” | — |
| 01-17 | Act | “Jesus carried that,” | — |
| 01-21 | In Jesus | “It is finished,” | — |
| 01-24 | In Jesus | “As the Father has sent me, even so I am sending you.” | — |
| 01-24 | Act | “What do you want me doing with my life?” | — |
| 01-25 | In Jesus | “If the Son sets you free, you will be free indeed.” | — |
| 02-08 | Act | “We're on the same team.” | — |
| 03-15 | Act | “Jesus, help me” | — |
| 04-13 | Act | “Jesus bore this” | — |
| 04-23 | Act | “I have peace with God because of You.” | — |
| 04-30 | Prayer | “I was wrong.” | — |
| 05-02 | Act | “I was wrong.” | — |
| 05-06 | Act | “I love you, and I am proud you are mine.” | — |
| 06-04 | In Jesus | “He has done all things well” | Mark 7:37 |
| 06-05 | In Jesus | “My Father is working until now, and I am working” | John 5:17 |
| 06-05 | In Jesus | “It is finished.” | John 5:17 |
| 06-06 | In Jesus | “I have come down from heaven, not to do my own will but the will of him who sent me” | John 6:38 |
| 06-09 | In Jesus | “I am the bread of life; whoever comes to me shall not hunger” | John 6:35 |
| 06-20 | In Jesus | “I am the good shepherd. I know my own and my own know me” | John 10:14 |
| 06-25 | Prayer | “if the Lord wills” | — |
| 06-25 | Act | “if the Lord wills” | — |
| 07-17 | In Jesus | “It is finished,” | — |
| 07-21 | In Jesus | “Do not be afraid, I am the first and the last.” | — |
| 07-26 | Act | “God is with us in this.” | — |
| 08-01 | Act | “Where do you see me drifting?” | — |
| 08-16 | Act | “I want to make this right.” | — |
| 08-17 | In Jesus | “Your sins are forgiven” | Mark 2:5 |
| 08-23 | Prayer | “Let me know if You need anything” | — |
| 09-02 | Act | “Jesus, help me” | — |
| 09-18 | Act | “Let me fix that” | — |
| 09-26 | Act | “Jesus already paid for me.” | — |
| 10-12 | Act | “Jesus, help,” | — |
| 10-18 | Act | “Praying for you by name.” | — |
| 10-22 | Act | “in Jesus' name,” | — |
| 10-25 | Act | “I prayed for you today.” | — |

## C. Every reference named in running text

82 mentions on 70 dates. Naming a reference is not quoting it, but it shows which verses the text leans on.

| Date | Part | Reference named | The day's verse | Among the bundled ESV verses? |
|---|---|---|---|---|
| 01-06 | Act | Psalm 139:14 | Psalm 139:14 | Yes |
| 01-19 | Act | Zephaniah 3:17 | Zephaniah 3:17 | Yes |
| 01-22 | Act | Psalm 51:10 | Psalm 51:10 | Yes |
| 04-01 | Act | Isaiah 53:5 | Isaiah 53:5 | Yes |
| 04-03 | Act | John 3:16 | John 3:16 | Yes |
| 04-05 | Act | 2 Corinthians 5:21 | 2 Corinthians 5:21 | Yes |
| 04-06 | Act | Luke 22:42 | Luke 22:42 | Yes |
| 06-02 | In Jesus | Mark 6:3 | Genesis 2:15 | No (1 verse) |
| 06-03 | In Jesus | John 19:26-27 | 1 Timothy 5:8 | No (2 verses) |
| 06-04 | In Jesus | Mark 7:37 | Proverbs 22:29 | No (1 verse) |
| 06-05 | In Jesus | John 5:17 | Proverbs 10:4 | No (1 verse) |
| 06-06 | In Jesus | John 6:38 | Proverbs 16:3 | No (1 verse) |
| 06-08 | In Jesus | Mark 10:45 | 2 Thessalonians 3:10 | Yes |
| 06-09 | In Jesus | John 6:35 | Proverbs 12:11 | No (1 verse) |
| 06-11 | In Jesus | Luke 19:10 | Matthew 6:33 | No (1 verse) |
| 06-12 | Act | Matthew 6 | Matthew 6:34 | A chapter, not a verse |
| 06-13 | In Jesus | John 14:6 | Proverbs 11:1 | No (1 verse) |
| 06-14 | In Jesus | Mark 1:35 | Mark 1:35 | Yes |
| 06-19 | In Jesus | John 13:3-5 | Matthew 20:26 | No (3 verses) |
| 06-20 | In Jesus | John 10:14 | Proverbs 27:23 | No (1 verse) |
| 06-21 | In Jesus | John 10:11 | Psalm 23:2–3 | No (1 verse) |
| 06-21 | In Jesus | Mark 6:31 | Psalm 23:2–3 | Yes |
| 06-21 | Act | Psalm 23 | Psalm 23:2–3 | A chapter, not a verse |
| 06-22 | In Jesus | 1 John 3:16 | Proverbs 14:23 | No (1 verse) |
| 06-23 | In Jesus | Luke 9:51 | Nehemiah 6:3 | No (1 verse) |
| 06-24 | In Jesus | Luke 6:12-13 | Proverbs 21:5 | No (2 verses) |
| 06-29 | In Jesus | Mark 4:38 | Proverbs 24:33–34 | No (1 verse) |
| 07-12 | Act | Psalm 56:3 | Psalm 56:3 | Yes |
| 08-02 | In Jesus | John 15:15 | Proverbs 18:24 | No (1 verse) |
| 08-02 | In Jesus | Hebrews 2:11 | Proverbs 18:24 | No (1 verse) |
| 08-03 | In Jesus | 1 Peter 2:24 | Galatians 6:2 | Yes |
| 08-04 | In Jesus | Ephesians 5:25 | Hebrews 10:24–25 | Yes |
| 08-05 | In Jesus | Hebrews 4:15 | James 5:16 | Yes |
| 08-06 | In Jesus | 2 Corinthians 8:9 | 1 Samuel 18:1 | No (1 verse) |
| 08-07 | In Jesus | Hebrews 7:25 | Exodus 17:12 | No (1 verse) |
| 08-08 | In Jesus | John 1:14 | Proverbs 27:6 | Yes |
| 08-08 | In Jesus | 1 Peter 2:24 | Proverbs 27:6 | Yes |
| 08-09 | In Jesus | Romans 5:8 | John 15:13 | Yes |
| 08-10 | In Jesus | Romans 5:6 | Proverbs 17:17 | No (1 verse) |
| 08-11 | In Jesus | John 21:15-17 | 1 Thessalonians 5:11 | No (2 verses) |
| 08-12 | In Jesus | John 21 | Galatians 6:1 | A chapter, not a verse |
| 08-12 | In Jesus | Matthew 12:20 | Galatians 6:1 | No (1 verse) |
| 08-13 | In Jesus | Mark 3:14 | Proverbs 13:20 | No (1 verse) |
| 08-13 | In Jesus | 1 Corinthians 1:30 | Proverbs 13:20 | No (1 verse) |
| 08-14 | In Jesus | 2 Corinthians 5:21 | 1 Corinthians 15:33 | Yes |
| 08-15 | In Jesus | John 13 | Acts 2:42 | A chapter, not a verse |
| 08-16 | In Jesus | Ephesians 2:14 | Psalm 133:1 | No (1 verse) |
| 08-16 | In Jesus | Romans 5:10 | Psalm 133:1 | No (1 verse) |
| 08-17 | In Jesus | Mark 2:5 | Mark 2:3–5 | Yes |
| 08-18 | In Jesus | John 11:35 | Romans 12:15 | No (1 verse) |
| 08-19 | In Jesus | Romans 5:8 | Matthew 18:15 | Yes |
| 08-20 | In Jesus | Mark 10:45 | Philippians 2:4 | Yes |
| 08-21 | In Jesus | Mark 6:7 | Proverbs 27:9 | No (1 verse) |
| 08-22 | In Jesus | 2 Corinthians 1:20 | 2 Samuel 9:7 | No (1 verse) |
| 08-23 | In Jesus | 1 John 3:16 | 1 John 3:18 | No (1 verse) |
| 08-24 | In Jesus | Luke 7:34 | Proverbs 12:26 | No (1 verse) |
| 08-24 | In Jesus | John 14:6 | Proverbs 12:26 | No (1 verse) |
| 08-25 | In Jesus | Hebrews 4:15 | 2 Timothy 2:22 | Yes |
| 08-26 | In Jesus | Matthew 28:19-20 | 2 Kings 2:2 | No (2 verses) |
| 08-27 | In Jesus | Acts 9 | Acts 9:27 | A chapter, not a verse |
| 08-27 | In Jesus | 1 John 2:1 | Acts 9:27 | No (1 verse) |
| 08-28 | In Jesus | Mark 14:38 | Hebrews 3:13 | No (1 verse) |
| 08-28 | In Jesus | Hebrews 7:25 | Hebrews 3:13 | No (1 verse) |
| 08-29 | In Jesus | John 1:14 | Colossians 3:16 | Yes |
| 08-30 | In Jesus | Revelation 19:11 | Proverbs 20:6 | No (1 verse) |
| 08-30 | In Jesus | 2 Timothy 2:13 | Proverbs 20:6 | No (1 verse) |
| 08-31 | In Jesus | John 13:1-5 | John 13:34–35 | No (5 verses) |
| 09-17 | In Jesus | Psalm 15 | Psalm 15:1–2 | A chapter, not a verse |
| 09-27 | Act | Psalm 139:23-24 | Psalm 139:23–24 | Yes |
| 10-05 | Act | Matthew 6:13 | Matthew 6:13 | Yes |
| 10-24 | Act | Mark 9:24 | Mark 9:24 | Yes |
| 11-02 | In Jesus | Luke 9:58 | Philippians 4:11–12 | No (1 verse) |
| 11-08 | In Jesus | Luke 17:19 | Luke 17:15–16 | No (1 verse) |
| 11-09 | In Jesus | John 6:35 | Ecclesiastes 5:10 | No (1 verse) |
| 11-10 | In Jesus | Mark 10:45 | Luke 12:15 | Yes |
| 11-11 | In Jesus | Acts 4:11 | Psalm 118:24 | No (1 verse) |
| 11-14 | In Jesus | John 19:30 | Galatians 6:4 | Yes |
| 11-24 | In Jesus | Mark 5:19 | Psalm 9:1 | No (1 verse) |
| 11-28 | In Jesus | Mark 4:38-39 | Psalm 121:3–4 | No (2 verses) |
| 11-28 | In Jesus | John 10:28 | Psalm 121:3–4 | No (1 verse) |
| 12-11 | Act | Luke 2:14 | Luke 2:14 | Yes |
| 12-25 | Act | Luke 2:1-20 | Matthew 1:23 | No (14 verses) |
