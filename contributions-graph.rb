require 'cadet'
require 'yaml'
require 'json'
require 'csv'

Cadet::BatchInserter::Session.open "neo4j-community-2.0.1/data/graph.db" do

  constraint :Contributor, :name
  constraint :Employer,    :name
  constraint :Occupation,  :name
  constraint :Recipient,   :name

  CSV.foreach("./data/FEC_Contributions_2012.csv", :headers => :first_row) do |row|
    next unless row["Contributor/Lender/Transfer Name 1"]

    contributor = Contributor_by_name row["Contributor/Lender/Transfer Name 1"]

    employment = create_Employment
    employment.employer_to   Employer_by_name(row["Employer"]) if row["Employer"]
    employment.occupation_to Occupation_by_name(row["Occupation"]) if row["Occupation"]

    contributor.employment_to employment

    contributor.contribution_to(Recipient_by_name(row["Recipient"])).tap do |contribution|
      contribution[:amount] = row["Amount"].gsub(/\$/, "").to_i
      contribution[:date]   = row["Transaction Date"].gsub(%r{(\d+)/(\d+)/(\d+)}, '\3\1\2').to_i
    end

  end

end
