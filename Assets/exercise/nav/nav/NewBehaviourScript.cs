using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


public class NewBehaviourScript : MonoBehaviour
{
    public Transform dest;
    // Start is called before the first frame update
    void Start()
    {
        NavMeshAgent agent = GetComponent<NavMeshAgent>();
        agent.destination = dest.position;
            //new Vector3(0,1.5f,44);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
