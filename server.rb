require 'sinatra'
require 'csv'
require 'shotgun'
require 'pry'


def read_file(csv)
  games = []

  CSV.foreach(csv, headers: true) do |row|
    game = {
      home_team: row["home_team"],
      away_team: row["away_team"],
      home_score: row["home_score"],
      away_score: row["away_score"]
    }
    games << game
  end
  games
end

def determine_winners
  games = read_file('scores.csv')

  win_tally = []
  games.each do |game|
    home_score = game[:home_score].to_i
    away_score = game[:away_score].to_i

    if home_score > away_score
      win_tally << game[:home_team]
    else away_score > home_score
      win_tally << game[:away_team]
    end
  end
  win_tally
end

def determine_losers
  games = read_file('scores.csv')

  loss_tally = []
  games.each do |game|
    home_score = game[:home_score].to_i
    away_score = game[:away_score].to_i

    if home_score < away_score
      loss_tally << game[:home_team]
    else away_score < home_score
      loss_tally << game[:away_team]
    end
  end
  loss_tally
end

def get_win_counts
  patriots_win_count = determine_winners.count("Patriots")
  broncos_win_count = determine_winners.count("Broncos")
  colts_win_count = determine_winners.count("Colts")
  steelers_win_count = determine_winners.count("Steelers")

  win_counts = {
    :Patriots => patriots_win_count,
    :Broncos => broncos_win_count,
    :Colts => colts_win_count,
    :Steelers => steelers_win_count
  }

  win_counts = win_counts.sort_by &:last
  win_counts = win_counts.reverse
end

def get_loss_counts
  patriots_loss_count = determine_losers.count("Patriots")
  broncos_loss_count = determine_losers.count("Broncos")
  colts_loss_count = determine_losers.count("Colts")
  steelers_loss_count = determine_losers.count("Steelers")

  loss_counts = {
    :Patriots => patriots_loss_count,
    :Broncos => broncos_loss_count,
    :Colts => colts_loss_count,
    :Steelers => steelers_loss_count
  }

  loss_counts
end

def get_teams
  win_counts = get_win_counts
  win_counts = win_counts.flatten
  teams = []
  winning_scores = []
  win_counts.each_slice(2) do |key, value|
    teams << key
    winning_scores << value
  end
  teams
end

def get_winning_scores
  win_counts = get_win_counts
  win_counts = win_counts.flatten
  teams = []
  winning_scores = []
  win_counts.each_slice(2) do |key, value|
    teams << key
    winning_scores << value
  end
  winning_scores
end

def get_losing_scores
  loss_counts = get_loss_counts
  loss_counts = loss_counts.flatten
  teams = []
  losing_scores = []
  loss_counts.each_slice(2) do |key, value|
    teams << key
    losing_scores << value
  end
  losing_scores
end

def rank_teams
  teams = get_teams
  winning_scores = get_winning_scores
  losing_scores = get_losing_scores

  ranking = []
  while winning_scores.count >= 2
    winning_scores.each do |score|
      if score[0] > score[1]
        ranking << teams[0]
        teams.shift
        winning_scores.shift
        losing_scores.shift
      elsif score[0] == score[1]
        if losing_scores[0].to_i <= losing_scores[1].to_i
          ranking << teams[0]
          teams.shift
          winning_scores.shift
          losing_scores.shift
        elsif losing_scores[0].to_i > losing_scores[1].to_i
          ranking << teams[1]
          teams.delete_at(1)
          winning_scores.delete_at(1)
          losing_scores.delete_at(1)
        end
      end
    end
  end
  final_team = teams[0]
  ranking << final_team
  ranking
end


get '/' do
  @teams = get_teams

  erb :index
end

get '/leaderboard' do
  @ranking = rank_teams
  @wins = get_winning_scores
  @losses = get_losing_scores.sort
  erb :leaderboard
end

get '/teams/:team_name' do

  erb :team
end


