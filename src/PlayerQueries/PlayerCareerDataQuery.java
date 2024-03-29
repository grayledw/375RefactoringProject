package PlayerQueries;

import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.sql.ResultSet;

import DatabaseQueries.DatabaseQuery;
import Domain.DatabaseConnectionService;
import Domain.PlayerName;

public class PlayerCareerDataQuery extends DatabaseQuery {
	private PlayerName playerName;
	
	public PlayerCareerDataQuery(DatabaseConnectionService dbService, PlayerName playerName) {
		super(dbService);
		this.playerName = playerName;
	}

	@Override
	protected void prepareCallableStatement() throws SQLException {
		callableStatement = dbService.getConnection().prepareCall("{?=call view_player_career(?,?)}");
		callableStatement.registerOutParameter(1, Types.INTEGER);
		callableStatement.setString(2, playerName.firstName);
		callableStatement.setString(3, playerName.lastName);
	}

	@Override
	protected List<String> getFormattedResultStrings(ResultSet resultSet) throws SQLException {
		List<String> results = new ArrayList<String>();
		while(resultSet.next()) {
			results.add("Career Points: " + resultSet.getString(3) + "\nCareer Assists: " + resultSet.getString(4)
					+ "\nCareer Rebounds: " + resultSet.getString(5));
		}
		
		return results;
	}

	@Override
	protected String queryToString() {
		return "view_player_career(" + playerName.firstName + "," + playerName.lastName + ")";
	}
}
