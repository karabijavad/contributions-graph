require 'cadet'
require 'yaml'
require 'json'
require 'csv'

Cadet::BatchInserter::Session.open "neo4j-community-2.0.1/data/graph.db" do

  CSV.foreach("./data/FEC_Contributions_2012.csv", :headers => :first_row) do |row|
    next unless row["Recipient"] and row["Contributor/Lender/Transfer Name 1"] and row["Employer"] and row["Occupation"]

    contributor = Contributor_by_name row["Contributor/Lender/Transfer Name 1"]

    if row["Employer"]
      employment = create_Employment({}).tap do |employment|
        employment.employer_to   Employer_by_name(row["Employer"])
        employment.occupation_to Occupation_by_name(row["Occupation"]) if row["Occupation"]
      end
    end

    contributor.employment_to employment

    contribution = create_Contribution({}).tap do |contribution|
      contribution.to_to Recipient_by_name(row["Recipient"])
      contribution[:amount] = row["Amount"].gsub(/\$/, "").to_i
      contribution[:date]   = row["Transaction Date"].gsub(%r{(\d+)/(\d+)/(\d+)}, '\3\1\2').to_i
    end

    contributor.contribution_to contribution

  end

end
