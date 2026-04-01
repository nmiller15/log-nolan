---
title: How To Test A Vertical Slice Architecture
date: 2026-03-09
summary: "Integration testing in ASP.NET"
description: "Integration testing in ASP.NET"
toc: false
readTime: true
autonumber: false
math: true
tags: ["dotnet", "testing"]
showTags: true
hideBackToTop: false
draft: true
dev: false
---

Recently, I got bitten by the bug that's making it's rounds through the .NET community: Vertical Slice Architecture. It's exciting! You can spend most of your time working on new features instead of debugging old ones, all of the code for specific actions will be grouped together, and you don't have to worry about your new features breaking any old ones because you reuse almost no code at all. If you think I'm crazy, take an hour to watch this [conference talk by Jimmy Bogard](https://www.youtube.com/watch?v=SUiWfhAhgQw).

For a project that I'm working on for a client that I'm not dedicating full-time hours to, it feels like the right choice. I want to be able to write it and leave it, and add new features over time as the requirements present themselves. It's actually some of the most fun that I've had working on enterprise-ish software, because of the speed and lack of boilerplate. 

There's just one issue. Testing. 

Take a look at the following example of a feature in my VSA application:

```cs
using System.Data;
using Investigations.Configuration;
using Investigations.Infrastructure.Data;
using Investigations.Infrastructure.Data.Extensions;
using Investigations.Models;
using Investigations.Models.Data;
using Serilog;

namespace Investigations.Features.Cases;

public class ListCases
{
    public class Query
    {
        public string SortColumn { get; set; } = "CaseNumber";
        public string SortDirection { get; set; } = "ASC";
        public bool ShowClosedCases { get; set; } = false;

        public class Result
        {
            public List<CaseRow> Cases { get; set; } = [];
        }
    }

    public class Handler(IConnectionStrings connectionStrings)
    {
        public async Task<MethodResponse<Query.Result>> Handle(Query query)
        {
            Log.Debug("Handling ListCases query with SortColumn: {SortColumn}, SortDirection: {SortDirection}, ShowClosedCases: {ShowClosedCases}",
                query.SortColumn, query.SortDirection, query.ShowClosedCases);
            try
            {
                var dcs = new DataCallSettings()
                {
                    ConnectionString = connectionStrings.DefaultConnection,
                    SqlQuery = $"""
                        SELECT 
                            case_key,
                            case_number,
                            is_active,
                            subject_key,
                            subject_first_name,
                            subject_last_name,
                            client_key,
                            client_name,
                            date_of_referral,
                            case_type_code
                        FROM v_cases
                        WHERE (@include_closed_cases = TRUE or is_active = TRUE)
                        ORDER BY
                            CASE WHEN @sort_direction = 'asc' THEN {SortColumn(query.SortColumn)} END ASC,
                            CASE WHEN @sort_direction = 'desc' THEN {SortColumn(query.SortColumn)} END DESC,
                            case_number ASC;
                        """,
                };

                dcs.AddParameter("sort_direction", query.SortDirection.ToLower());
                dcs.AddParameter("include_closed_cases", query.ShowClosedCases);

                var cases = await NpgsqlDataProvider.ExecuteRaw(dcs, new CaseRowParser());

                return MethodResponse<Query.Result>.Success(new Query.Result
                {
                    Cases = cases
                });
            }
            catch (Exception ex)
            {
                Log.Error(ex, "Error occurred while retrieving cases.");
                return MethodResponse<Query.Result>.Failure("An error occurred while retrieving cases. Please try again later.");
            }
        }

        public string SortColumn(string sortColumn)
        {
            return sortColumn.ToLower() switch
            {
                "casenumber" => "case_number",
                "subjectname" => "subject_last_name",
                "clientname" => "client_name",
                "dateofreferral" => "date_of_referral",
                "casetypecode" => "case_type_code",
                _ => "case_number"
            };
        }
    }

    public record CaseRow
    {
        public int CaseKey { get; set; }
        public string CaseNumber { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public int SubjectKey { get; set; }
        public string SubjectFirstName { get; set; } = string.Empty;
        public string SubjectLastName { get; set; } = string.Empty;
        public int ClientKey { get; set; }
        public string ClientName { get; set; } = string.Empty;
        public DateTime DateOfReferral { get; set; }
        public string CaseTypeCode { get; set; } = string.Empty;
    }

    public class CaseRowParser : ISqlDataParser<CaseRow>
    {
        public CaseRow Parse(IDataReader reader)
        {
            return new CaseRow
            {
                CaseKey = reader.ParseInt32("case_key"),
                CaseNumber = reader.ParseString("case_number"),
                IsActive = reader.ParseBool("is_active"),
                SubjectKey = reader.ParseInt32("subject_key"),
                SubjectFirstName = reader.ParseString("subject_first_name"),
                SubjectLastName = reader.ParseString("subject_last_name"),
                ClientKey = reader.ParseInt32("client_key"),
                ClientName = reader.ParseString("client_name"),
                DateOfReferral = reader.ParseDateTime("date_of_referral"),
                CaseTypeCode = reader.ParseString("case_type_code")
            };
        }
    }
}

```

This feature, as the class name might suggest, is a query for cases to list on a dashboard page to see all of the application's registered users. Using nested classes, the feature encapsulates the `Query` parameters, `Response`, `CaseRow` and `Handler` models. 

The `Handler` takes in the `Query`, fires off a raw SQL command to my Data Provider that wraps some connection logic for Npgsql. The query parameters decide how the data is going to be ordered when it comes out of the database. The provider uses the included parser to dump the information into a `CaseRow` and they're all sent up to the front end to be transformed into `ViewModels` and displayed on the page. 

Did you notice that there's really no way to inject unit testing in here?

When this handler is called, there's no abstraction layer between the call and us hitting the database. This is great for mental overhead and locality of behavior, but not so good for testing. So, what should we do?

Let's take a step back, because testing in this architecture will require us to think about testing differently than we would in a clean architecture.

