package utils

import (
	"encoding/json"
	"io/ioutil"
	"os"
)

type GlobalObj struct {
	Name string

	Host    string
	TCPPort int

	ConfFilePath string

	LogDir        string
	LogFile       string
	LogDebugClose bool
}

var GlobalObject *GlobalObj

func PathExists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}

func (g *GlobalObj) Reload() {

	if confFileExists, _ := PathExists(g.ConfFilePath); !confFileExists {
		//fmt.Println("Config File ", g.ConfFilePath , " is not exist!!")
		return
	}

	data, err := ioutil.ReadFile(g.ConfFilePath)
	if err != nil {
		panic(err)
	}

	err = json.Unmarshal(data, g)
	if err != nil {
		panic(err)
	}
}

func init() {
	pwd, err := os.Getwd()
	if err != nil {
		pwd = "."
	}

	GlobalObject = &GlobalObj{
		Name:    "BetServerApp",
		TCPPort: 8090,
		Host:    "0.0.0.0",

		ConfFilePath: pwd + "/conf/zinx.json",

		LogDir:        pwd + "/log",
		LogFile:       "",
		LogDebugClose: false,
	}

	GlobalObject.Reload()
}
