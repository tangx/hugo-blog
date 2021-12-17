package main

import (
	"context"
	"fmt"
)

type MysqlDriver struct{}

// Save message by driver
func (my *MysqlDriver) Save() {
	fmt.Println("mysql: save a record")
}

// global config
var (
	my = &MysqlDriver{}
)

func main() {

	// initial context and env
	ctx := context.Background()
	ctx = context.WithValue(ctx, "db", my)

	// pass ctx
	save(ctx)
}

// save use ctx as ioc to get mysql(db) driver
func save(ctx context.Context) {
	db := ctx.Value("db")
	my := db.(*MysqlDriver)

	my.Save()
}
