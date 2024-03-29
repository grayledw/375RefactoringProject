package TeamQueries;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import DatabaseQueries.DatabaseQuery;
import Domain.DatabaseConnectionService;

public class TeamSeasonDataQuery extends DatabaseQuery {
	private String teamName;
	private String year; 

	public TeamSeasonDataQuery(DatabaseConnectionService dbService, String teamName, String year) {
		super(dbService);
		this.teamName = teamName;
		this.year = year;
	}

	@Override
	protected void prepareCallableStatement() throws SQLException {
		callableStatement = dbService.getConnection().prepareCall("{?=call team_season_data(?, ?)}");
		callableStatement.registerOutParameter(1, Types.INTEGER);
		callableStatement.setString(2, teamName);
		callableStatement.setString(3, year);
	}

	@Override
	protected List<String> getFormattedResultStrings(ResultSet resultSet) throws SQLException {
		List<String> results = new ArrayList<String>();
		while(resultSet.next()) {
			results.add("Season Points For: " + resultSet.getString(1) + "\nSeason Points Against: " + resultSet.getString(2) + "\nWin Percentage: " + resultSet.getString(3));
		}
		
		return results;
	}

	@Override
	protected String queryToString() {
		return "team_season_data(" + teamName + "," + year + ")";
	}
}
