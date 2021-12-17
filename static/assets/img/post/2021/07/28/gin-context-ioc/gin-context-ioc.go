package main

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

// 实现一个驱动
type MysqlDriver struct {
}

func (my *MysqlDriver) Save(record string) {
	fmt.Printf("mysql driver save record: %s\n", record)
}

func main() {
	r := gin.Default()
	r.Use(GinContextIoC) // 使用 middleware 的方式在 context 中注入与传递

	r.POST("/gin-ioc", CreateHanlder)
	r.Run()
}

func GinContextIoC(c *gin.Context) {
	c.Set("db", &MysqlDriver{}) // 写入驱动
}

func CreateHanlder(c *gin.Context) {
	// 1.
	// db := c.Value("db")

	// 2.
	db, exists := c.Get("db")
	if !exists {
		return
	}
	my := db.(*MysqlDriver)
	my.Save("username=zhangsan")

	c.String(http.StatusAccepted, "job accpet: user creating")
}
