using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScaleTransformation : Transformation {

    public Vector3 scale;

    public override Matrix4x4 Matrix {
        get
        {
            Matrix4x4 matrix = new Matrix4x4();
            matrix.SetColumn(0, new Vector4(scale.x, 0f, 0f, 0f));
            matrix.SetColumn(1, new Vector4(0f, scale.y, 0f, 0f));
            matrix.SetColumn(2, new Vector4(0f, 0f, scale.z, 0f));
            matrix.SetColumn(3, new Vector4(0f, 0f, 0f, 1f));
            return matrix;
        }
    }
}
