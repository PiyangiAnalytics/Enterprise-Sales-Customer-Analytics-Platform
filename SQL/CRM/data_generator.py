"""
SQL/CRM/data_generator.py

Generates synthetic CRM data for ContosoCRM, keyed to the real CustomerIDs
already sitting in ContosoERP, with deliberately planted data-quality defects
logged to planted_defects.csv (the answer key for Phase 5's quality work).
"""
import os
import random
from datetime import timedelta, datetime

import pandas as pd
import pyodbc
from faker import Faker

fake = Faker()
random.seed(42)
Faker.seed(42)

ERP_CONN_STR = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=localhost;DATABASE=ContosoERP;"
    "Trusted_Connection=yes;TrustServerCertificate=yes;"
)
CRM_CONN_STR = ERP_CONN_STR.replace("ContosoERP", "ContosoCRM")

OUTPUT_DIR = "generated_data"

N_REPS = 35
N_CAMPAIGNS = 35
N_LEADS = 3500
N_OPPORTUNITIES = 3500
N_INTERACTIONS = 5000

REGIONS = ["NSW", "VIC", "QLD", "WA", "SA", "TAS", "ACT", "NT"]
CHANNELS = ["Email", "Social Media", "Webinar", "Trade Show", "Referral", "Cold Call"]
LEAD_SOURCES = ["Website", "Referral", "Campaign", "Cold Call", "Partner"]
LEAD_STATUSES = ["New", "Contacted", "Qualified", "Disqualified", "Converted"]
OPP_STAGES = ["Open", "Qualifying", "Proposal", "Negotiation", "Closed Won", "Closed Lost"]

defects = []  # every planted defect, across every function, lands here


def log_defect(defect_type, table, key_column, key_value, detail):
    defects.append({
        "defect_type": defect_type,
        "table": table,
        "key_column": key_column,
        "key_value": key_value,
        "detail": detail,
        "planted_at": datetime.now().isoformat(timespec="seconds"),
    })


# ---------- pull the real customer universe from ERP ----------

def get_erp_customer_ids():
    with pyodbc.connect(ERP_CONN_STR) as conn:
        df = pd.read_sql("SELECT DISTINCT CustomerID FROM erp.SalesOrder", conn)
    return df["CustomerID"].dropna().astype(int).tolist()


# ---------- reference data ----------

def generate_sales_representatives(n=N_REPS):
    rows = [{
        "RepID": rep_id,
        "FirstName": fake.first_name(),
        "LastName": fake.last_name(),
        "Region": random.choice(REGIONS),
        "HireDate": fake.date_between(start_date="-6y", end_date="-30d"),
    } for rep_id in range(1, n + 1)]
    return pd.DataFrame(rows)


def generate_campaigns(n=N_CAMPAIGNS):
    rows = []
    for campaign_id in range(1, n + 1):
        start = fake.date_between(start_date="-2y", end_date="-30d")
        end = start + timedelta(days=random.randint(14, 90))
        rows.append({
            "CampaignID": campaign_id,
            "CampaignName": f"{random.choice(['Spring','Winter','Q1','Q2','Q3','Q4','Flash'])} "
                            f"{random.choice(['Sale','Promo','Launch','Clearance'])} {campaign_id}",
            "Channel": random.choice(CHANNELS),
            "StartDate": start,
            "EndDate": end,
            "Budget": round(random.uniform(2000, 50000), 2),
        })
    return pd.DataFrame(rows)


# ---------- customers, keyed to real ERP CustomerIDs ----------

def generate_customers(customer_ids):
    rows = [{
        "CustomerID": cid,
        "FirstName": fake.first_name(),
        "LastName": fake.last_name(),
        "Email": fake.unique.email(),
        "Phone": fake.phone_number()[:30],
        "Region": random.choice(REGIONS),
    } for cid in customer_ids]
    df = pd.DataFrame(rows)

    # Defect: missing / invalid emails (~1% each)
    n_missing = max(1, int(len(df) * 0.01))
    n_invalid = max(1, int(len(df) * 0.01))
    missing_idx = df.sample(n=n_missing, random_state=1).index
    invalid_idx = df.drop(missing_idx).sample(n=n_invalid, random_state=2).index

    for idx in missing_idx:
        cid = df.loc[idx, "CustomerID"]
        df.loc[idx, "Email"] = None
        log_defect("missing_email", "Customer", "CustomerID", cid, "Email set to NULL")

    for idx in invalid_idx:
        cid = df.loc[idx, "CustomerID"]
        bad_email = random.choice(["not-an-email", "missing.at.sign.com", "@nodomain", "spaced out@x.com"])
        df.loc[idx, "Email"] = bad_email
        log_defect("invalid_email", "Customer", "CustomerID", cid, f"Email set to '{bad_email}'")

    return df


def build_duplicate_customers(customers_df, n=5):
    """'Same person, two CRM records' duplicates, on out-of-band negative IDs
    that cannot collide with a real ERP CustomerID. This is the one deliberate
    exception to 'reuse real ERP IDs' -- everything else in Customer uses the
    real IDs pulled from ContosoERP."""
    sample = customers_df.sample(n=n, random_state=3)
    dup_rows = []
    for i, (_, row) in enumerate(sample.iterrows(), start=1):
        dup_id = -i
        dup_rows.append({
            "CustomerID": dup_id,
            "FirstName": row["FirstName"],
            "LastName": row["LastName"],
            "Email": row["Email"],
            "Phone": row["Phone"],
            "Region": row["Region"],
        })
        log_defect("duplicate_customer", "Customer", "CustomerID", dup_id,
                    f"Duplicate of real CustomerID {row['CustomerID']} (same name/email)")
    return pd.DataFrame(dup_rows)


# ---------- leads, opportunities, interactions ----------

def generate_leads(campaign_ids, n=N_LEADS):
    rows = [{
        "LeadID": lead_id,
        "CampaignID": random.choice(campaign_ids) if random.random() > 0.1 else None,
        "LeadSource": random.choice(LEAD_SOURCES),
        "Status": random.choices(LEAD_STATUSES, weights=[30, 25, 20, 15, 10])[0],
    } for lead_id in range(1, n + 1)]
    return pd.DataFrame(rows)


def generate_opportunities(customer_ids, rep_ids, n=N_OPPORTUNITIES):
    rows = []
    for opp_id in range(1, n + 1):
        created = fake.date_time_between(start_date="-18m", end_date="now")
        stage = random.choices(OPP_STAGES, weights=[15, 20, 20, 15, 15, 15])[0]
        close_date = created + timedelta(days=random.randint(5, 120)) if stage in ("Closed Won", "Closed Lost") else None
        rows.append({
            "OpportunityID": opp_id,
            "CustomerID": random.choice(customer_ids),
            "RepID": random.choice(rep_ids),
            "Stage": stage,
            "EstimatedValue": round(random.uniform(500, 75000), 2),
            "CloseDate": close_date,
            "_CreatedDate": created,  # dropped before saving -- only used to plant the date defect below
        })
    df = pd.DataFrame(rows)

    # Defect: impossible dates (CloseDate before the opportunity was even created)
    eligible = df[df["CloseDate"].notna()]
    n_bad = min(8, len(eligible))
    if n_bad:
        closed_idx = eligible.sample(n=n_bad, random_state=4).index
        for idx in closed_idx:
            created = df.loc[idx, "_CreatedDate"]
            bad_close = created - timedelta(days=random.randint(1, 30))
            df.loc[idx, "CloseDate"] = bad_close
            log_defect("impossible_date", "Opportunity", "OpportunityID", df.loc[idx, "OpportunityID"],
                        f"CloseDate {bad_close} is before CreatedDate {created}")

    return df.drop(columns=["_CreatedDate"])


def build_orphan_opportunities(customer_ids, rep_ids, n=5, start_id=900001):
    """Opportunity rows referencing CustomerIDs that exist nowhere -- loaded
    with the FK constraint briefly disabled (see load_to_sql), simulating the
    classic real-world cause of orphaned foreign keys: a bulk load run with
    constraints off that never got cleaned up afterwards."""
    fake_customer_ids = [max(customer_ids) + 1000 + i for i in range(n)]
    rows = []
    for i, opp_id in enumerate(range(start_id, start_id + n)):
        cid = fake_customer_ids[i]
        rows.append({
            "OpportunityID": opp_id,
            "CustomerID": cid,
            "RepID": random.choice(rep_ids),
            "Stage": "Open",
            "EstimatedValue": round(random.uniform(500, 20000), 2),
            "CloseDate": None,
        })
        log_defect("orphaned_fk", "Opportunity", "OpportunityID", opp_id,
                    f"CustomerID {cid} does not exist in Customer")
    return pd.DataFrame(rows)


def generate_interactions(customer_ids, rep_ids, n=N_INTERACTIONS):
    types = ["Call", "Email", "Meeting", "Support Ticket", "Demo"]
    rows = [{
        "InteractionID": interaction_id,
        "CustomerID": random.choice(customer_ids),
        "RepID": random.choice(rep_ids) if random.random() > 0.05 else None,
        "InteractionType": random.choice(types),
        "InteractionDate": fake.date_time_between(start_date="-18m", end_date="now"),
        "Notes": fake.sentence(nb_words=10),
    } for interaction_id in range(1, n + 1)]
    return pd.DataFrame(rows)


# ---------- load into ContosoCRM ----------

def _to_sql_value(v):
    """Null-safe, pyodbc-safe scalar conversion: NaN/NaT/None -> None, and any
    pandas Timestamp -> a plain Python datetime (pandas' own Timestamp carries
    extra precision that pyodbc can mis-bind against a SQL DATETIME column)."""
    if pd.isna(v):
        return None
    if isinstance(v, pd.Timestamp):
        return v.to_pydatetime()
    return v


def insert_dataframe(cursor, table, df, columns, has_identity=False):
    if has_identity:
        cursor.execute(f"SET IDENTITY_INSERT {table} ON;")
    col_list = ", ".join(columns)
    placeholders = ", ".join("?" for _ in columns)
    sql = f"INSERT INTO {table} ({col_list}) VALUES ({placeholders})"
    data = [tuple(_to_sql_value(v) for v in row)
            for row in df[columns].itertuples(index=False, name=None)]
    cursor.executemany(sql, data)
    if has_identity:
        cursor.execute(f"SET IDENTITY_INSERT {table} OFF;")


def load_to_sql(reps, campaigns, all_customers, leads, opportunities, orphan_opps, interactions):
    with pyodbc.connect(CRM_CONN_STR, autocommit=True) as conn:
        cursor = conn.cursor()
        # fast_executemany is OFF on purpose: it infers each column's SQL
        # type/size from the FIRST row of the batch only, and several columns
        # here (CloseDate, RepID, CampaignID) are NULL on an arbitrary first
        # row -- that combination causes a spurious "Datetime field overflow"
        # once a real value shows up later in the batch. At a few thousand
        # rows per table, the slower, per-row-safe path costs a few seconds.
        cursor.fast_executemany = False

        insert_dataframe(cursor, "dbo.SalesRepresentative", reps,
                          ["RepID", "FirstName", "LastName", "Region", "HireDate"],
                          has_identity=True)
        insert_dataframe(cursor, "dbo.Campaign", campaigns,
                          ["CampaignID", "CampaignName", "Channel", "StartDate", "EndDate", "Budget"],
                          has_identity=True)
        insert_dataframe(cursor, "dbo.Customer", all_customers,
                          ["CustomerID", "FirstName", "LastName", "Email", "Phone", "Region"])
        insert_dataframe(cursor, "dbo.Lead", leads,
                          ["LeadID", "CampaignID", "LeadSource", "Status"],
                          has_identity=True)
        insert_dataframe(cursor, "dbo.Opportunity", opportunities,
                          ["OpportunityID", "CustomerID", "RepID", "Stage", "EstimatedValue", "CloseDate"],
                          has_identity=True)
        insert_dataframe(cursor, "dbo.CustomerInteraction", interactions,
                          ["InteractionID", "CustomerID", "RepID", "InteractionType", "InteractionDate", "Notes"],
                          has_identity=True)

        # Orphans deliberately break FK_Opportunity_Customer -- disable it just
        # for this one insert, then re-enable (re-enabling does NOT retroactively
        # validate existing rows, so the orphans stay in place on purpose).
        cursor.execute("ALTER TABLE dbo.Opportunity NOCHECK CONSTRAINT FK_Opportunity_Customer;")
        insert_dataframe(cursor, "dbo.Opportunity", orphan_opps,
                          ["OpportunityID", "CustomerID", "RepID", "Stage", "EstimatedValue", "CloseDate"],
                          has_identity=True)
        cursor.execute("ALTER TABLE dbo.Opportunity CHECK CONSTRAINT FK_Opportunity_Customer;")


# ---------- main ----------

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    customer_ids = get_erp_customer_ids()
    print(f"Pulled {len(customer_ids)} real CustomerIDs from ContosoERP.")

    reps = generate_sales_representatives()
    campaigns = generate_campaigns()
    customers = generate_customers(customer_ids)
    dup_customers = build_duplicate_customers(customers)
    all_customers = pd.concat([customers, dup_customers], ignore_index=True)

    leads = generate_leads(campaigns["CampaignID"].tolist())
    opportunities = generate_opportunities(customer_ids, reps["RepID"].tolist())
    orphan_opps = build_orphan_opportunities(customer_ids, reps["RepID"].tolist())
    all_opportunities = pd.concat([opportunities, orphan_opps], ignore_index=True)

    interactions = generate_interactions(customer_ids, reps["RepID"].tolist())

    # CSVs first, exactly as planned -- inspectable and reproducible before anything touches SQL
    reps.to_csv(f"{OUTPUT_DIR}/sales_representative.csv", index=False)
    campaigns.to_csv(f"{OUTPUT_DIR}/campaign.csv", index=False)
    all_customers.to_csv(f"{OUTPUT_DIR}/customer.csv", index=False)
    leads.to_csv(f"{OUTPUT_DIR}/lead.csv", index=False)
    all_opportunities.to_csv(f"{OUTPUT_DIR}/opportunity.csv", index=False)
    interactions.to_csv(f"{OUTPUT_DIR}/customer_interaction.csv", index=False)
    print(f"Wrote 6 CSVs to {OUTPUT_DIR}/")

    load_to_sql(reps, campaigns, all_customers, leads, opportunities, orphan_opps, interactions)
    print("Loaded all tables into ContosoCRM.")

    pd.DataFrame(defects).to_csv("planted_defects.csv", index=False)
    print(f"Logged {len(defects)} planted defects to planted_defects.csv.")


if __name__ == "__main__":
    main()
