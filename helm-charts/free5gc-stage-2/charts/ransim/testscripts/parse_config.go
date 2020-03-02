package test

import (
	"gofree5gc/lib/nas/nasType"

	"encoding/hex"
	"io/ioutil"

	"gopkg.in/yaml.v2"
)

type UeData struct {
	Supi              string `yaml:"supi"`
	RanUeNgapId       int64  `yaml:"ranUeNgapId"`
	AmfUeNgapId       int64  `yaml:"amfUeNgapId"`
	Sst               int32  `yaml:"sst"`
	Sd                string `yaml:"sd"`
	MobileIdentity5GS nasType.MobileIdentity5GS
}

var Ues []UeData

func ParseConfig(f string) error {
	content, err := ioutil.ReadFile(f)
	if err != nil {
		return err
	}

	var ueConfig []UeData
	err = yaml.Unmarshal([]byte(content), &ueConfig)
	if err != nil {
		return err
	}

	// calculate MobileIdentity5GS with MSIN in Little Endian
	for idx, ue := range ueConfig {
		char_1 := ue.Supi[len(ue.Supi)-1:]
		char_2 := ue.Supi[len(ue.Supi)-2 : len(ue.Supi)-1]
		decoded, err := hex.DecodeString(char_1 + char_2)
		if err != nil {
			return err
		}

		buf := []uint8{0x01, 0x02, 0xf8, 0x39, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x47}
		buf = append(buf, []uint8(decoded)...)
		ueConfig[idx].MobileIdentity5GS = nasType.MobileIdentity5GS{
			Len:    12,
			Buffer: buf,
		}
	}

	Ues = append(Ues, ueConfig...)

	return nil
}
