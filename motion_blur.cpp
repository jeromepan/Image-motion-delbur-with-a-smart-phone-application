
<pre class="cpp" name="code">void genaratePsf(Mat &psf, double len,double angle)
{
	double half=len/2;											
	double alpha = (angle-floor(angle/ 180) *180) /180* PI;
	double cosalpha = cos(alpha);
	double sinalpha = sin(alpha);
	int xsign;
	if (cosalpha < 0)
	{
		xsign = -1;
	}
	else
	{
		if (angle == 90)
		{
			xsign = 0;
		}
		else
		{
			xsign = 1;
		}
	}
	int psfwdt = 1;
	int sx = (int)fabs(half*cosalpha + psfwdt*xsign - len*EPS);
	int sy = (int)fabs(half*sinalpha + psfwdt - len*EPS);
	Mat_<double> psf1(sy, sx, CV_64F);
	Mat_<double> psf2(sy * 2, sx * 2, CV_64F);
	int row = 2 * sy;
	int col = 2 * sx;
	/*为减小运算量，先计算一半大小的PSF*/
	for (int i = 0; i < sy; i++)
	{
		double* pvalue = psf1.ptr<double>(i);
		for (int j = 0; j < sx; j++)
		{
			pvalue[j] = i*fabs(cosalpha) - j*sinalpha;

			double rad = sqrt(i*i + j*j);
			if (rad >= half && fabs(pvalue[j]) <= psfwdt)
			{
				double temp = half - fabs((j + pvalue[j] * sinalpha) / cosalpha);
				pvalue[j] = sqrt(pvalue[j] * pvalue[j] + temp*temp);
			}
			pvalue[j] = psfwdt + EPS - fabs(pvalue[j]);
			if (pvalue[j] < 0)
			{
				pvalue[j] = 0;
			}
		}
	}
	/*将模糊核矩阵扩展至实际大小*/
	for (int i = 0; i < sy; i++)
	{
		double* pvalue1 = psf1.ptr<double>(i);
		double* pvalue2 = psf2.ptr<double>(i);
		for (int j = 0; j < sx; j++)
		{
			pvalue2[j] = pvalue1[j];
		}
	}

	for (int i = 0; i < sy; i++)
	{
		for (int j = 0; j < sx; j++)
		{
			psf2[2 * sy -1 - i][2 * sx -1 - j] = psf1[i][j];
			psf2[sy + i][j] = 0;
			psf2[i][sx + j] = 0;
		}
	}
	/*保持图像总能量不变，归一化矩阵*/
	double sum = 0;
	for (int i = 0; i < row; i++)
	{
		for (int j = 0; j < col; j++)
		{
			sum+= psf2[i][j];
		}
	}
	psf2 = psf2 / sum;
	if (cosalpha>0)
	{
		flip(psf2, psf2, 0);
	}

	//cout << "psf2=" << psf2 << endl;
	psf = psf2;