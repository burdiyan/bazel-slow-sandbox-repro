package app

import "crawshaw.io/sqlite/sqlitex"

type App struct {
	db *sqlitex.Pool
}
