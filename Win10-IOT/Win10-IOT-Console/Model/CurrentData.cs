using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Win10_IOT_Console.Model
{
    class CurrentData
    {
        public List<Sensor> Sensors { get; private set; }

        public CurrentData()
        {
            Sensors = new List<Sensor>();
        }
    }
}
