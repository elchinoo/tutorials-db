# Database Tutorials

Hello all, I hope you are doing great! This repo is intended to be the main repo of the Database tutorials we are creating. 

## Translations

You can collaborate with this project helping to translate and/or with reviews. Please feel free to fork this project, add your contributions and send us a PR!

You can find below the currently available translations.

- [Brazilian Portuguese (Português Brasileiro)](https://github.com/elchinoo/tutorials-db/blob/main/README_PT-BR.md)
- [中文（简体）(Chinese Simplified)](https://github.com/elchinoo/tutorials-db/blob/main/README_CN.md)

## Project goals

The main goal of this project is to introduce people to this amazing world of data. Many companies haven't realized that their second most valuable asset is data (the most valuable is you!). Because of that, I've often heard something like "we are too small to work on our data" or "this is only the database"... These misconceptions are causing companies to leak important data, too lose precious data, go offline for some time and in extreme situations even shut down the whole business operations!

To address our goal we will start from the beginning, teaching the concepts of data, models, and some relational algebra to then evolve to database modeling. Note that at this point we are not bound to a specific database, and everything can be used with any relational database in the market. During this first course, we’ll also walk you through SQL and the construction of queries. We’ll start with basic statements and understand how to create relations (tables), how to populate those relations, and how to get the data back (select). Even though I don't intend to go through super complex constructions in this first course (because of time constraints), I intend to walk you through a few intermediate concepts like Window Functions and CTEs (common table expressions), so you will be able to solve the problem proposed in this challenge [here[1]](https://github.com/elchinoo/tutorials-db/blob/main/challenge_1.md).

This first course is an introduction to the database world and expects no knowledge of databases or data at all, and anybody can be able to follow along. The following courses require the knowledge acquired here though. If you already have the pre-required knowledge you are free to skip this first one.

Ok, now that we have good knowledge about data, modeling, SQL, and the importance of keeping the database sane, it's time to learn how to administrate our database. Here we’ll have different courses with both different focuses and levels of complexity. It’s still a work in progress but the goal is to go from installation, basic configuration, backups, tuning, and troubleshooting of a single instance to environments with multiple instances using both asynchronous and synchronous replication and moving to high availability using tools like Patroni for coordination, pgBackRest for backup strategy and Percona PMM for monitoring. It seems a long way to go but we intend you to be able to fully install, configure, troubleshoot, optimize… administer with knowledge and confidence a production PostgreSQL environment. 

It’s important to note here that while we don't intend to have all the formalism of academic texts and courses we need some of them, and it can be inferred from the relational algebra mentioned above. Don’t be scared though, we will explain and walk you through all the needed knowledge here. We’ll also try to create our own material with booklets, text tutorials, examples, etc, but will always try to mention good bibliographic references. We intend to give enough knowledge for you to follow the texts and books we reference.

## How will it work?

Okay, I know what we’ll learn (well, I hope you do, if not, please send over any doubt or question about what is discussed above), but how would it work? Videos? Only texts?

First things first, the “program” here will be divided into different courses and we’ll try to make it as sequential and logical as possible. That said, we’ll have videos and I’ll try to make it live streams so we can have interaction and answer questions during the lives. All the videos will be posted on video stream media like Youtube and I will try to follow the questions in the comments. Also, as with any formal training, we’ll have exercises and homework that you need to solve. This is vital and I strongly encourage you to answer all the questions!

## Important information

This material is been created to help everyone that wants or needs to enter this world. It may help one to get a better score in the university, maybe get a better job, enter the market, or just have a better understanding of how a database works… That said, BE POLITE with everybody, try to help each other, and if find anything that is incorrect, misinformation, etc, please report back, it helps to keep the quality of this material! Also, this is collaborative work, if you have suggestions, extra material, or want to translate this to your mother language please send us a PR, we are glad to incorporate it!

That all said, I hope you all enjoy our journey here and see you on our next live!!!


[1] https://github.com/elchinoo/tutorials-db/blob/main/challenge_1.md 
