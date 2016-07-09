using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Win10_IOT_Console.Model
{
    class Sensor
    {
        public String Name { get; set; }
        public String Topic { get; set; }
        public List<SensorValue> Values { get; private set; }

        public Sensor()
        {
            Values = new List<SensorValue>();
        }
    }
}
